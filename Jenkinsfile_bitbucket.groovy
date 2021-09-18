// -*- mode: groovy -*-
// vim: set filetype=groovy :
import groovy.transform.Field
import hudson.model.Result
import jenkins.model.CauseOfInterruption
import org.jenkinsci.plugins.workflow.steps.FlowInterruptedException
@Library('agora-build-pipeline-library') _

@Field def releaseBranchPattern = ~/^release\/(\d+.\d+.\d+(.\d)?)_[a-z]+$|arsenal/
@Field def repoName = "open-cloudclass-ios"
@Field def repoBranch = ""
@Field def companionBranch = ''
@Field def companionReposConfig = [
    "open-cloudclass-ios": "ssh://git@git.agoralab.co/aduc/open-cloudclass-ios.git",
    "apaas-common-libs-ios": "ssh://git@git.agoralab.co/aduc/apaas-common-libs-ios.git",
    "cloudclass-ios": "ssh://git@git.agoralab.co/aduc/cloudclass-ios.git"
]

withWechatNotify {
    withKnownErrorHandling {
        timestamps {
            repoBranch = env.CHANGE_BRANCH ?: env.BRANCH_NAME
            companionBranch = env.CHANGE_TARGET ?: env.BRANCH_NAME

            def branches = [:]
            commitPrInfo = companionPullRequestsChecker(companionReposConfig, repoBranch, branches)

            def job_util = new agora.build.JobUtils()
            job_util.abortPreviousRunningBuilds(commitPrInfo)

            def buildParams = [
                string(name: 'build_branch', value: branches["cloudclass-ios"] ?: companionBranch),
                string(name: 'open_cloud_class_branch', value: branches["open-cloudclass-ios"] ?: companionBranch),
                string(name: 'common_libs_branch', value: branches["apaas-common-libs-ios"] ?: companionBranch),
                string(name: 'ci_branch', value: 'new_ios'),
                string(name: 'build_env', value: 'Debug'),
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
    def companionPrInfo = [:]
    REPOS.each {k, v ->
        branches."${k}" = ''
        repoGroup = v.split("/")[-2]
        try {
            response = utils.sendBitbucketRequest("GET", "rest/api/latest/projects/${repoGroup}/repos/${k}/commits?until=${repoBranch}&limit=0&start=0")
        } catch (Exception ex) {
            echo "***** error message: ${ex.getMessage()}"
            error("SourceControlConnectionError")
        }

        if(response?.status == 200) {
            branches."${k}" = repoBranch
            def found = false
            response = utils.sendBitbucketRequest("GET", "rest/api/1.0/projects/${repoGroup}/repos/${k}/pull-requests?direction=outgoing&at=refs/heads/${repoBranch}")
            pullRequest = readJSON text: response.content
            if(pullRequest.values) {
                companionPrInfo."${k}" = pullRequest.values[0].id
                found = true
            }

            if(!found) {
                error("***** No Companion Pull Request found. Please submit pull requests for branch ${repoBranch} of ${v} *****")
            } else {
                echo "***** Companion Pull Request found. *****"
            }
        }
    }
    return companionPrInfo
}
