// -*- mode: groovy -*-
// vim: set filetype=groovy :
import groovy.transform.Field
import hudson.model.Result
import jenkins.model.CauseOfInterruption
import org.apache.commons.codec.digest.DigestUtils
import org.jenkinsci.plugins.workflow.steps.FlowInterruptedException
@Library('agora-build-pipeline-library') _

@Field def releaseBranchPattern = ~/Flex/
@Field def repoName = "open-cloudclass-ios"
@Field def repoBranch = ""
@Field def companionBranch = ""
@Field def companionPrInfo = [:]
@Field def companionCommitInfo = [:]
@Field def companionReposConfig = [
    "open-cloudclass-ios": "ssh://git@git.agoralab.co/aduc/open-cloudclass-ios.git",
    "apaas-common-libs-ios": "ssh://git@git.agoralab.co/aduc/apaas-common-libs-ios.git",
    "cloudclass-ios": "ssh://git@git.agoralab.co/aduc/cloudclass-ios.git",
    "open-apaas-extapp-ios": "ssh://git@git.agoralab.co/aduc/open-apaas-extapp-ios.git",
    "common-scene-sdk": "ssh://git@git.agoralab.co/aduc/common-scene-sdk.git"
]

withWechatNotify {
    withKnownErrorHandling {
        timestamps {
            repoBranch = env.CHANGE_BRANCH ?: env.BRANCH_NAME
            companionBranch = env.CHANGE_TARGET ?: env.BRANCH_NAME

            def branches = [:]
            (companionCommitInfo, companionPrInfo) = companionPullRequestsChecker(companionReposConfig, repoBranch, branches)
            println(companionPrInfo)
            println(companionCommitInfo)

            abortPreviousRunningBuilds(companionPrInfo)

            def buildParams = [
                string(name: 'build_branch', value: branches["cloudclass-ios"] ?: companionBranch),
                string(name: 'open_cloud_class_branch', value: branches["open-cloudclass-ios"] ?: companionBranch),
                string(name: 'common_libs_branch', value: branches["apaas-common-libs-ios"] ?: companionBranch),
                string(name: 'open_widgets_extapps_branch', value: branches["open-apaas-extapp-ios"] ?: companionBranch),
                string(name: 'rte_branch', value: branches["common-scene-sdk"] ?: companionBranch),
                string(name: 'ci_branch', value: 'new_ios'),
                string(name: 'build_env', value: 'Debug'),
                booleanParam(name: 'Package_Publish', value: false),
                booleanParam(name: 'appstore', value: false)
            ]

            parallel( IOSBuild: {
                stage('Compile on IOS') {
                    build job: 'AD/Agora-CloudClass-iOS', parameters: buildParams, wait: true
                }
            }, failFast: true)
        }
    }
}

def withKnownErrorHandling(Closure block) {
    def utils = new agora.build.Utils()
    try {
        block()
        currentBuild.result = "SUCCESS"
    } catch (Exception ex) {
        currentBuild.result = "FAILURE"
        throw ex
    } finally {
        updateAllRepoStatus(companionCommitInfo, companionPrInfo)
    }
}

def currentCommitHash() {
    return commitHashForBuild( currentJenkinsBuild() )
}

@NonCPS
def currentJenkinsBuild() {
    def job = Jenkins.instance.getItemByFullName( env.JOB_NAME )
    return job.getBuild( env.BUILD_ID )
}

@NonCPS
def commitHashForBuild( build ) {
    def scmAction = build?.actions.find { action -> action instanceof jenkins.scm.api.SCMRevisionAction }
    return scmAction?.revision?.hasProperty('hash') ? scmAction?.revision?.hash : scmAction?.revision
}

def withWechatNotify(Closure block) {
    try {
        block()
    } catch (FlowInterruptedException fie) {
        echo "Info: Cancelled by afterwards build, ignore warning."
    } catch (Exception ex) {
        if (repoBranch ==~ releaseBranchPattern ) {
            head = '<font color=\\"red\\">Main Branch failed </font>. Please deal with them as soon as possible.\\n'
            branch = ">**${env.BRANCH_NAME}**" + '\\n'
            url = ">[${env.RUN_DISPLAY_URL}](${env.RUN_DISPLAY_URL})" + '\\n'
            exeception = ">Info: ${ex.toString()}"
            content = "${head}${branch}${url}${exeception}"
            def payload = """
                {
                    "msgtype": "markdown",
                    "markdown": {
                        "content": \"${content}\"
                    }
                }
                """
            httpRequest httpMode: 'POST',
                    acceptType: 'APPLICATION_JSON_UTF8',
                    contentType: 'APPLICATION_JSON_UTF8',
                    ignoreSslErrors: true,
                    responseHandle: 'STRING',
                    requestBody: payload,
                    url: "https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=6742e321-b00b-4efb-9c76-456a5b59e867"
        }
        throw ex
    }
}

def companionPullRequestsChecker(REPOS, repoBranch, branches) {
    def utils = new agora.build.Utils()
    def prInfo = [:]
    def commitInfo = [:]
    def companionPrDetails = [:]
    REPOS.each {k, v ->
        branches."${k}" = ''
        repoGroup = v.split("/")[-2]
        try {
            response = utils.sendBitbucketRequest("GET", "rest/api/latest/projects/${repoGroup}/repos/${k.toString().toLowerCase()}/commits?until=${repoBranch}&limit=0&start=0")
        } catch (Exception ex) {
            echo "***** error message: ${ex.getMessage()}"
            error("SourceControlConnectionError")
        }

        if(response?.status == 200) {
            branches."${k}" = repoBranch
            def commits = readJSON text: response.content
            commitInfo."${k}" = commits['values'][0]['id']

            def found = false
            response = utils.sendBitbucketRequest("GET", "rest/api/1.0/projects/${repoGroup}/repos/${k}/pull-requests?direction=outgoing&at=refs/heads/${repoBranch}")
            pullRequest = readJSON text: response.content
            if(pullRequest.values) {
                prInfo."${k}" = pullRequest.values[0].id
                companionPrDetails."${k}" = pullRequest.values[0]
                found = true
            }

            if(!found) {
                error("***** No Companion Pull Request found. Please submit pull requests for branch ${repoBranch} of ${v} *****")
            } else {
                echo "***** Companion Pull Request found. *****"
            }
        }
    }
    utils.updateCompanionPullRequestsDetails(companionPrDetails)
    return [commitInfo, prInfo]
}

def abortPreviousRunningBuilds(prInfo) {
    def instance = Hudson.instance
    def prBuilds = []
    prInfo.each { k, v ->
        prBuilds.add("AD/${k}/PR-${v}")
    }

    def current_build_starttime = currentBuild.getStartTimeInMillis()
    println "current build start time is: ${current_build_starttime}"

    prBuilds.each { item ->
            instance.getItemByFullName(item)?.getBuilds().each{ build ->
            def exec = build.getExecutor()

            if (exec != null) {
                // skip current build
                if (item == env.JOB_NAME && build.number == currentBuild.number) {
                    return true
                }

                exec.interrupt(
                    Result.ABORTED,
                    new CauseOfInterruption.UserInterruption(
                    "Aborted by companion pr build #${currentBuild.absoluteUrl}"
                    )
                )
                println("Aborted companion pr build #${item}/${build.number}")
            }
        }
    }
}

def updateAllRepoStatus(commitInfo, prInfo) {
    def utils = new agora.build.Utils()
    commitInfo.each { repo, commit ->
        echo repo
        echo commit
        def response = utils.sendBitbucketRequest('GET', "rest/build-status/1.0/commits/${commit}")

        if (response.status == 200) {
            def statuses = readJSON text: response.content
            def compile_status = statuses.values.find { it.name.contains(repo) && it.name.contains("AD") }
            def pr_id = prInfo."${repo}"
            if (!compile_status) {
                def buildName = pr_id ? "AD/${repo}/PR-${pr_id}" : "${currentBuild.rawBuild.getParent().getParent().getFullName()}/${repo}/${env.BRANCH_NAME}"
                utils.notifyStash(currentBuild, commit, DigestUtils.md5Hex(buildName), "Companion build ${repo}: ${currentBuild.fullDisplayName}", env)
            } else {
                utils.notifyStash(currentBuild, commit, compile_status['key'], compile_status['name'], env)
            }
        } else {
            error("SourceControlConnectionError")
        }
    }
}
