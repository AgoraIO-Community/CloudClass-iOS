//
//  AnswerSheetExtApp.swift
//  AgoraExtApp
//
//  Created by Jonathan on 2021/10/27.
//

import UIKit
import Masonry

class AnswerSheetModel: Decodable {
    var answer: [String] = [String]()
    var canChange: Bool = false
    var endTime: String?
    var items: [String] = [String]()
    var mulChoice: Bool = false
    var startTime: String?
    var state: String?
    var studentNames: [String] = [String]()
    var students: [String] = [String]()
    var uuid: String = ""
    var replies: [AnswerSheetItemModel] = [AnswerSheetItemModel]()
    
    enum CodingKeys: String, CodingKey {
        case answer, canChange, endTime, items, mulChoice,
             startTime, state, studentNames, students
    }
}

class AnswerSheetItemModel: Decodable {
    var name: String = ""
    var uuid: String = ""
    var answer: [String] = [String]()
    var replyTime: String = ""
    var startTime: String = ""
    
    enum CodingKeys: String, CodingKey {
        case answer, replyTime
    }
}

class AnswerSheetExtApp: AgoraBaseExtApp {
    
    var sheetView: UIView?
    
    override func extAppWillUnload() {
        super.extAppWillUnload()
    }
    
    override func extAppDidLoad(_ context: AgoraExtAppContext) {
        super.extAppDidLoad(context)
        if localUserInfo.userRole == "teacher" && context.properties.isEmpty {
            let v = self.setupSheetViewUse(cls: AnswerSheetSetupView.self)
            v?.delegate = self
        }
    }
    
    override func propertiesDidUpdate(_ properties: [AnyHashable : Any]) {
        super.propertiesDidUpdate(properties)
        guard let data = try? JSONSerialization.data(withJSONObject: properties, options: []),
              let model = try? JSONDecoder().decode(AnswerSheetModel.self, from: data) else {
            return
        }
        print("properties: \(properties)")
        model.uuid = localUserInfo.userUuid
        // 数据解析
        var tempReplies = [AnswerSheetItemModel]()
        for (i, uuid) in model.students.enumerated() {
            let idKey = "student\(uuid)"
            guard let replyDict = properties[idKey] as? [String: Any],
                  let replyData = try? JSONSerialization.data(withJSONObject: replyDict, options: []),
                  let replyModel = try? JSONDecoder().decode(AnswerSheetItemModel.self, from: replyData) else {
                continue
            }
            replyModel.name = model.studentNames[i]
            replyModel.uuid = uuid
            tempReplies.append(replyModel)
        }
        model.replies = tempReplies
        let r = localUserInfo.userRole
        // 按条件显示
        if r == "student" {
            let reply = model.replies.first(where: {$0.uuid == localUserInfo.userUuid})
            if (reply != nil && model.canChange == false) || model.state == "end" {
                // 学生答过题且不能修改, 或者答题状态已经结束
                let v = self.setupSheetViewUse(cls: AnswerSheetStudentResultView.self)
                v?.setupWithModel(model)
            } else {
                let v = self.setupSheetViewUse(cls: AnswerSheetSelecterView.self)
                v?.delegate = self
                v?.setupWithModel(model)
            }
        } else if r == "teacher" {
            if model.answer.count == 0 || model.items.count == 0 {
                self.setupSheetViewUse(cls: AnswerSheetSetupView.self)
            } else {
                let v = self.setupSheetViewUse(cls: AnswerSheetResultView.self)
                v?.setupWithModel(model)
            }
        }
    }
}
// MARK: - Private
extension AnswerSheetExtApp {
    @discardableResult
    func setupSheetViewUse<T: UIView>(cls: T.Type) -> T? {
        if let sheetView = self.sheetView,
           sheetView.isKind(of: T.self) == false {
            sheetView.removeFromSuperview()
            self.sheetView = nil
        }
        if self.sheetView == nil {
            let v = T(frame: .zero)
            self.view.addSubview(v)
            v.mas_makeConstraints { make in
                make?.center.equalTo()(0)
            }
            self.sheetView = v
        }
        return self.sheetView as? T
    }
}
// MARK: - AnswerSheetSelecterViewDelegate
extension AnswerSheetExtApp: AnswerSheetSelecterViewDelegate {
    func onSubmitAnswer(answers:[String]) {
        let interval = Int(Date().timeIntervalSince1970)
        let idKey = "student\(self.localUserInfo.userUuid)"
        let params: [String: Any] = [idKey: ["answer": answers, "replyTime": String(interval)]]
        self.updateProperties(params) {
            print("answer: update properties successs")
        } fail: { ero in
            print("answer: update properties fail")
        }
    }
}
// MARK: - AnswerSheetSelecterViewDelegate
extension AnswerSheetExtApp: AnswerSheetSetupViewDelegate {
    func onSubmitSetup(items: [String], answers: [String]) {
        let interval = Int(Date().timeIntervalSince1970)
        let params: [String: Any] = [
            "answer": answers,
            "items": items,
            "mulChoice": true,
            "startTime": String(interval),
            "state": "start",
            "canChange": true,
            "endTime": "",
            "studentNames": [],
            "students": []
        ]
        self.updateProperties(params) {
            print("answer: update properties successs")
        } fail: { ero in
            print("answer: update properties fail")
        }
    }
    
}
