//
//  RoomCreateTimeAlertController.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/9/7.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit
import AgoraUIBaseViews

class RoomCreateTimeAlertController: UIViewController {
    
    static func showTimeSelection(in viewController: UIViewController,
                                  from: Date,
                                  complete: ((Date) -> Void)?) {
        let vc = RoomCreateTimeAlertController()
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        vc.complete = complete
        vc.fromDate = from
        viewController.present(vc,
                               animated: true)
    }
    
    private let kComponentDay: Int = 0
    private let kComponentHour: Int = 1
    private let kComponentMinute: Int = 2
    
    private var complete: ((Date) -> Void)?
    
    private var fromDate: Date? {
        didSet {
            guard let date = fromDate ?? Date() else {
                return
            }
            var temp = [Date]()
            var day = date
            temp.append(day)
            for _ in 0..<6 {
                day = day.tomorrow
                temp.append(day)
            }
            days = temp
            pickerView.reloadComponent(kComponentDay)
            currentDaySelected = true
        }
    }
        
    private let contentView = UIView()
    
    private let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    private let alertBg = UIImageView(image: UIImage(named: "fcr_alert_bg"))
    
    private let titleLabel = UILabel()
    
    private let closeButton = UIButton(type: .custom)
    
    private let submitButton = UIButton(type: .custom)
    
    private let cancelButton = UIButton(type: .custom)
    
    private let pickerView = UIPickerView(frame: .zero)
    
    private var days = [Date]()
    
    private var hours = [Int]()
    
    private var minutes = [Int]()
    
    private var currentDaySelected = false {
        didSet {
            guard currentDaySelected != oldValue else {
                return
            }
            hours.removeAll()
            var startHour = 0
            if currentDaySelected {
                startHour = fromDate?.hour ?? 0
            }
            var hour = 0
            while hour < 24 {
                if hour >= startHour {
                    hours.append(hour)
                }
                hour += 1
            }
            pickerView.reloadComponent(kComponentHour)
            currentHourSelected = currentDaySelected
        }
    }
    
    private var currentHourSelected = false {
        didSet {
            guard currentHourSelected != oldValue else {
                return
            }
            minutes.removeAll()
            var startMinutes = 0
            if currentHourSelected {
                startMinutes = fromDate?.minute ?? 0
            }
            var minute = 0
            while minute <= 60 {
                if minute >= startMinutes {
                    minutes.append(minute)
                }
                minute += 5
            }
            pickerView.reloadComponent(kComponentMinute)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        createViews()
        createConstrains()
        
        setupCurrent()
    }
}
// MARK: - Actions
private extension RoomCreateTimeAlertController {
    @objc func onClickCancel(_ sender: UIButton) {
        dismiss(animated: true)
        complete = nil
    }
    
    @objc func onClickSubmmit(_ sender: UIButton) {
        var date = days[pickerView.selectedRow(inComponent: kComponentDay)]
        date.hour = hours[pickerView.selectedRow(inComponent: kComponentHour)]
        date.minute = minutes[pickerView.selectedRow(inComponent: kComponentMinute)]
        guard date > Date() else {
            AgoraToast.toast(message: "fcr_create_tips_starttime".ag_localized(),
                             type: .warning)
            return
        }
        complete?(date)
        dismiss(animated: true)
        complete = nil
    }
    
    func setupCurrent() {
        let date = Date()
        let dayIndex = days.firstIndex(where: {$0.day == date.day}) ?? 0
        pickerView.selectRow(dayIndex,
                             inComponent: kComponentDay,
                             animated: true)
        pickerView.selectRow(date.hour,
                             inComponent: kComponentHour,
                             animated: true)
        pickerView.selectRow(date.minute,
                             inComponent: kComponentMinute,
                             animated: true)
    }
}
// MARK: - UIPickerView Call Back
extension RoomCreateTimeAlertController: UIPickerViewDelegate,
                                         UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        if component == kComponentDay {
            return days.count
        } else if component == kComponentHour {
            return hours.count
        } else if component == kComponentMinute {
            return minutes.count
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    widthForComponent component: Int) -> CGFloat {
        if component == kComponentDay {
            return 140
        } else if component == kComponentHour {
            return 60
        } else if component == kComponentMinute {
            return 60
        } else {
            return 0
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    viewForRow row: Int,
                    forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? {
            let v = UILabel()
            v.font = UIFont.boldSystemFont(ofSize: 16)
            v.textColor = .black
            v.textAlignment = .center
            return v
        }()
        label.text = self.pickerView(pickerView,
                                     titleForRow: row,
                                     forComponent: component)
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        if component == kComponentDay {
            let date = days[row]
            if row == 0 {
                return "fcr_create_picker_today".ag_localized()
            } else {
                return date.string(withFormat: "fcr_create_picker_time_format".ag_localized())
            }
        } else if component == kComponentHour {
            let h = hours[row]
            return String(format: "%02d",
                          h)
        } else if component == kComponentMinute {
            let m = minutes[row]
            return String(format: "%02ld", m)
        } else {
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        if component == kComponentDay {
            currentDaySelected = (row == 0)
            pickerView.selectRow(0,
                                 inComponent: kComponentHour,
                                 animated: false)
            pickerView.selectRow(0,
                                 inComponent: kComponentMinute,
                                 animated: false)
        } else if component == kComponentHour {
            currentHourSelected = (row == 0 && currentDaySelected)
            pickerView.selectRow(0,
                                 inComponent: kComponentMinute,
                                 animated: false)
        }
    }
}
// MARK: - Creations
private extension RoomCreateTimeAlertController {
    func createViews() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 40
        contentView.clipsToBounds = true
        view.addSubview(contentView)
        
        contentView.addSubview(effectView)
        contentView.addSubview(alertBg)
        
        titleLabel.textColor = .black
        titleLabel.text = "fcr_create_select_start_time".ag_localized()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        contentView.addSubview(titleLabel)
        
        closeButton.setImage(UIImage(named: "fcr_room_create_alert_cancel"),
                             for: .normal)
        closeButton.addTarget(self,
                              action: #selector(onClickCancel(_:)),
                              for: .touchUpInside)
        contentView.addSubview(closeButton)
        
        submitButton.setTitle("fcr_alert_sure".ag_localized(),
                              for: .normal)
        submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        submitButton.addTarget(self,
                               action: #selector(onClickSubmmit(_:)),
                               for: .touchUpInside)
        submitButton.setTitleColor(.white,
                                   for: .normal)
        submitButton.layer.cornerRadius = 23
        submitButton.clipsToBounds = true
        submitButton.backgroundColor = UIColor(hex: 0x357BF6)
        contentView.addSubview(submitButton)
        
        cancelButton.setTitle("fcr_alert_cancel".ag_localized(),
                              for: .normal)
        cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        cancelButton.addTarget(self,
                               action: #selector(onClickCancel(_:)),
                               for: .touchUpInside)
        cancelButton.setTitleColor(.black,
                                   for: .normal)
        cancelButton.layer.cornerRadius = 23
        cancelButton.clipsToBounds = true
        cancelButton.backgroundColor = UIColor(hex: 0xF8F8F8)
        contentView.addSubview(cancelButton)
        
        pickerView.delegate = self
        pickerView.dataSource = self
        contentView.addSubview(pickerView)
    }
    
    func createConstrains() {
        contentView.mas_makeConstraints { make in
            make?.left.equalTo()(16)
            make?.right.bottom().equalTo()(-16)
            make?.height.equalTo()(354)
        }
        effectView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        alertBg.mas_makeConstraints { make in
            make?.top.left().equalTo()(0)
        }
        titleLabel.mas_makeConstraints { make in
            make?.left.top().equalTo()(24)
        }
        closeButton.mas_makeConstraints { make in
            make?.top.equalTo()(15)
            make?.right.equalTo()(-15)
        }
        pickerView.mas_makeConstraints { make in
            make?.top.equalTo()(60)
            make?.left.equalTo()(20)
            make?.right.equalTo()(-20)
            make?.bottom.equalTo()(-93)
        }
        submitButton.mas_makeConstraints { make in
            make?.bottom.equalTo()(-30)
            make?.right.equalTo()(-12)
            make?.height.equalTo()(46)
            make?.width.equalTo()(190)
        }
        cancelButton.mas_makeConstraints { make in
            make?.centerY.equalTo()(submitButton)
            make?.right.equalTo()(submitButton.mas_left)?.offset()(-15)
            make?.height.equalTo()(46)
            make?.width.equalTo()(110)
        }
    }
}
