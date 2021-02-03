//
//  AgoraCourseComfirAlertView.swift
//  AgoraEduSDK
//
//  Created by ZYP on 2021/2/1.
//

import UIKit

public class AgoraCourseComfirAlertView: AgoraBaseView {
    
    /// UI类型：`未到下课时间`
    public static let type1 = 0
    /// UI类型：`已到下课时间`
    public static let type2 = 1
    /// UI类型`课程结束`
    public static let type3 = 3
    
    /// 响应类型：灰色非高亮按钮。
    /// 如：`取消`、`退出教室`
    public static let actionNonHighlight = 0
    /// 响应类型：黄色高亮。
    /// 如：`确定`、`再想一下`
    public static let actionHighlight = 1
    /// 响应类型：点击关闭。
    public static let actionClose = 2
    
    public typealias TapActionBlock = (Int) -> ()

    let nonHighlightButton = UIButton()
    let highlightButton = UIButton()
    let closeButton = UIButton()
    let tipsLabel = UILabel()
    let bgView = UIView()
    let contentView = UIView()
    let contentBgView = UIView()
    let imageView = UIImageView()
    var type = type1
    public var didTapAction: TapActionBlock?
    
    func setup() {
        
        var nonHighlightButtonTitle = ""
        var highlightButtonTitle = ""
        var tipText = ""
        var nonHighlightButtonHiden = false
        var highlightButtonLeadingConstant: CGFloat = 0.0
        if type == AgoraCourseComfirAlertView.type1 {
            nonHighlightButtonTitle = "退出教室"
            highlightButtonTitle = "再想一下"
            tipText = "课程还没结束，是否确定要退出教室？"
            nonHighlightButtonHiden = false
            highlightButtonLeadingConstant = 10
        }
        else if type == AgoraCourseComfirAlertView.type2 {
            nonHighlightButtonTitle = "取消"
            highlightButtonTitle = "确定"
            tipText = "是否确定退出教室？"
            nonHighlightButtonHiden = false
            highlightButtonLeadingConstant = 10
        }
        else {
            nonHighlightButtonTitle = ""
            highlightButtonTitle = "确定"
            tipText = "课程已结束！"
            nonHighlightButtonHiden = true
            highlightButtonLeadingConstant = -1 * (69.3/2)
        }
        
        highlightButton.setTitle(highlightButtonTitle, for: .normal)
        highlightButton.backgroundColor = UIColor(hex: 0xDFB635)
        highlightButton.layer.cornerRadius = 10
        highlightButton.layer.masksToBounds = true
        highlightButton.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        
        nonHighlightButton.setTitle(nonHighlightButtonTitle, for: .normal)
        nonHighlightButton.backgroundColor = UIColor(hex: 0xA7A7A7)
        nonHighlightButton.layer.cornerRadius = 10
        nonHighlightButton.layer.masksToBounds = true
        nonHighlightButton.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        nonHighlightButton.isHidden = nonHighlightButtonHiden
        
        backgroundColor = .clear
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        contentView.backgroundColor = UIColor(hex: 0x75C0FF)
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        contentBgView.backgroundColor = .white
        contentBgView.layer.cornerRadius = 7
        contentBgView.layer.masksToBounds = true
        
        imageView.image = Bundle.agoraEduBundle.image(name: "alertLogo")
        
        tipsLabel.text = tipText
        tipsLabel.textColor = UIColor(hex: 0x002591)
        tipsLabel.font = UIFont.systemFont(ofSize: 10)
        
        closeButton.setTitle("", for: .normal)
        closeButton.setImage(Bundle.agoraEduBundle.image(name: "alertExit"), for: .normal)

        translatesAutoresizingMaskIntoConstraints = true
        bgView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        tipsLabel.translatesAutoresizingMaskIntoConstraints = false
        nonHighlightButton.translatesAutoresizingMaskIntoConstraints = false
        highlightButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentBgView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(bgView)
        addSubview(contentView)
        contentView.addSubview(contentBgView)
        contentView.addSubview(tipsLabel)
        contentView.addSubview(nonHighlightButton)
        contentView.addSubview(highlightButton)
        contentView.addSubview(closeButton)
        contentView.addSubview(imageView)
        
        bgView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bgView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bgView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bgView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        contentView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        contentView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: 140).isActive = true
        contentView.widthAnchor.constraint(equalToConstant: 216.66).isActive = true
        
        contentBgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        contentBgView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        contentBgView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        contentBgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true

        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: contentBgView.topAnchor, constant: 7).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 48.6).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 44.6).isActive = true
        
        tipsLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        tipsLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 11).isActive = true

        nonHighlightButton.bottomAnchor.constraint(equalTo: contentBgView.bottomAnchor, constant: -13).isActive = true
        nonHighlightButton.trailingAnchor.constraint(equalTo: contentBgView.centerXAnchor, constant: -13).isActive = true
        nonHighlightButton.widthAnchor.constraint(equalToConstant: 69.3).isActive = true
        nonHighlightButton.heightAnchor.constraint(equalToConstant: 23).isActive = true

        highlightButton.bottomAnchor.constraint(equalTo: contentBgView.bottomAnchor, constant: -13).isActive = true
        highlightButton.leadingAnchor.constraint(equalTo: contentBgView.centerXAnchor, constant: highlightButtonLeadingConstant).isActive = true
        highlightButton.widthAnchor.constraint(equalToConstant: 69.3).isActive = true
        highlightButton.heightAnchor.constraint(equalToConstant: 23).isActive = true

        closeButton.topAnchor.constraint(equalTo: contentBgView.topAnchor, constant: 10).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: contentBgView.trailingAnchor, constant: -13).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 11).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 11).isActive = true
    }
    
    func setup1() {
        
        var nonHighlightButtonTitle = ""
        var highlightButtonTitle = ""
        var tipText = ""
        var nonHighlightButtonHiden = false
        var highlightButtonLeadingConstant: CGFloat = 0.0
        if type == AgoraCourseComfirAlertView.type1 {
            nonHighlightButtonTitle = "退出教室"
            highlightButtonTitle = "再想一下"
            tipText = "课程还没结束，是否确定要退出教室？"
            nonHighlightButtonHiden = false
            highlightButtonLeadingConstant = 15
        }
        else if type == AgoraCourseComfirAlertView.type2 {
            nonHighlightButtonTitle = "取消"
            highlightButtonTitle = "确定"
            tipText = "是否确定退出教室？"
            nonHighlightButtonHiden = false
            highlightButtonLeadingConstant = 15
        }
        else {
            nonHighlightButtonTitle = ""
            highlightButtonTitle = "确定"
            tipText = "课程已结束！"
            nonHighlightButtonHiden = true
            highlightButtonLeadingConstant = -1 * (104/2)
        }
        
        highlightButton.setTitle(highlightButtonTitle, for: .normal)
        highlightButton.backgroundColor = UIColor(hex: 0xDFB635)
        highlightButton.layer.cornerRadius = 35/2
        highlightButton.layer.masksToBounds = true
        highlightButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        highlightButton.tag = AgoraCourseComfirAlertView.actionHighlight
        
        nonHighlightButton.setTitle(nonHighlightButtonTitle, for: .normal)
        nonHighlightButton.backgroundColor = UIColor(hex: 0xA7A7A7)
        nonHighlightButton.layer.cornerRadius = 35/2
        nonHighlightButton.layer.masksToBounds = true
        nonHighlightButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        nonHighlightButton.isHidden = nonHighlightButtonHiden
        nonHighlightButton.tag = AgoraCourseComfirAlertView.actionNonHighlight
        
        backgroundColor = .clear
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        contentView.backgroundColor = UIColor(hex: 0x75C0FF)
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        contentBgView.backgroundColor = .white
        contentBgView.layer.cornerRadius = 7
        contentBgView.layer.masksToBounds = true
        
        imageView.image = Bundle.agoraEduBundle.image(name: "alertLogo")
        
        tipsLabel.text = tipText
        tipsLabel.textColor = UIColor(hex: 0x002591)
        tipsLabel.font = UIFont.systemFont(ofSize: 15)
        
        closeButton.setTitle("", for: .normal)
        closeButton.setImage(Bundle.agoraEduBundle.image(name: "alertExit"), for: .normal)
        closeButton.tag = AgoraCourseComfirAlertView.actionClose

        translatesAutoresizingMaskIntoConstraints = true
        bgView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        tipsLabel.translatesAutoresizingMaskIntoConstraints = false
        nonHighlightButton.translatesAutoresizingMaskIntoConstraints = false
        highlightButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentBgView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(bgView)
        addSubview(contentView)
        contentView.addSubview(contentBgView)
        contentView.addSubview(tipsLabel)
        contentView.addSubview(nonHighlightButton)
        contentView.addSubview(highlightButton)
        contentView.addSubview(closeButton)
        contentView.addSubview(imageView)
        
        bgView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bgView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bgView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bgView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        contentView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        contentView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: 420/2).isActive = true
        contentView.widthAnchor.constraint(equalToConstant: 650/2).isActive = true
        
        contentBgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        contentBgView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        contentBgView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        contentBgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true

        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: contentBgView.topAnchor, constant: 7).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 146/2).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 134/2).isActive = true
        
        tipsLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        tipsLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 15).isActive = true

        nonHighlightButton.bottomAnchor.constraint(equalTo: contentBgView.bottomAnchor, constant: -20).isActive = true
        nonHighlightButton.trailingAnchor.constraint(equalTo: contentBgView.centerXAnchor, constant: -15).isActive = true
        nonHighlightButton.widthAnchor.constraint(equalToConstant: 104).isActive = true
        nonHighlightButton.heightAnchor.constraint(equalToConstant: 35).isActive = true

        highlightButton.bottomAnchor.constraint(equalTo: contentBgView.bottomAnchor, constant: -20).isActive = true
        highlightButton.leadingAnchor.constraint(equalTo: contentBgView.centerXAnchor, constant: highlightButtonLeadingConstant).isActive = true
        highlightButton.widthAnchor.constraint(equalToConstant: 104).isActive = true
        highlightButton.heightAnchor.constraint(equalToConstant: 35).isActive = true

        closeButton.topAnchor.constraint(equalTo: contentBgView.topAnchor, constant: 10).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: contentBgView.trailingAnchor, constant: -10).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 11).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 11).isActive = true
    }
    
    func commonInit() {
        nonHighlightButton.addTarget(self, action: #selector(buttonTap(button:)), for: .touchUpInside)
        highlightButton.addTarget(self, action: #selector(buttonTap(button:)), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(buttonTap(button:)), for: .touchUpInside)
    }
    
    
    /// 设置显示类型
    /// - Parameter type: 类型值。
    /// type 可选如下：
    /// - `AgoraCourseComfirAlertView.type1` 表示”未到下课时间“弹出框
    /// - `AgoraCourseComfirAlertView.type2` 表示“已到下课时间”弹出框
    /// - `AgoraCourseComfirAlertView.type3` 表示“课程结束”弹出框
    public func setType(type: Int = AgoraCourseComfirAlertView.type1) {
        self.type = type
        setup1()
        commonInit()
    }
    
    @objc public func show(in view: UIView) {
        self.contentView.alpha = 0
        let transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        self.contentView.transform = transform
        
        view.addSubview(self)
        
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.55, delay: 0.2, usingSpringWithDamping: 0.3, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
            self.contentView.alpha = 1
            self.contentView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            view.layoutIfNeeded()
        } completion: { (_) in
            
        }
    }
    
    func dismiss(action: Int) {
        UIView.animate(withDuration: 0.25) {
            self.alpha = 0
        } completion: { (_) in
            self.removeFromSuperview()
            self.didTapAction?(action)
        }
    }
    
    @objc func buttonTap(button: UIButton) {
        dismiss(action: button.tag)
    }

}
