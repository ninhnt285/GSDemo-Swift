//
//  DJIGSButtonControllerViewController.swift
//  GSDemo-Swift
//
//  Created by Thanh Ninh Nguyen on 3/7/23.
//

import UIKit

enum DJIGSViewMode {
    case view
    case edit
}

protocol DJIGSButtonViewControllerDelegate {
    func stopBtnActionInGSButtonVC(GSBtnVC: DJIGSButtonViewController)
    func clearBtnActionInGSButtonVC(GSBtnVC: DJIGSButtonViewController)
    func focusBtnActionInGSButtonVC(GSBtnVC: DJIGSButtonViewController)
    func startBtnActionInGSButtonVC(GSBtnVC: DJIGSButtonViewController)
    func addBtnActionInGSButtonVC(addBtn: UIButton, GSBtnVC: DJIGSButtonViewController)
    func configBtnActionInGSButtonVC(GSBtnVC: DJIGSButtonViewController)
    func switchToMode(_ mode: DJIGSViewMode, inGSButtonVC GSBtnVC: DJIGSButtonViewController)
}

class DJIGSButtonViewController: UIViewController {
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var configBtn: UIButton!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var focusBtn: UIButton!
    
    var delegate: DJIGSButtonViewControllerDelegate?
    var mode: DJIGSViewMode = .view
    
    func setMode(mode: DJIGSViewMode) {
        self.mode = mode
        
        editBtn.isHidden = (mode == .edit)
        focusBtn.isHidden = (mode == .edit)
        
        backBtn.isHidden = (mode == .view)
        clearBtn.isHidden = (mode == .view)
        startBtn.isHidden = (mode == .view)
        stopBtn.isHidden = (mode == .view)
        addBtn.isHidden = (mode == .view)
        configBtn.isHidden = (mode == .view)
    }
    
    
    @IBAction func backBtnAction(_ sender: Any) {
        self.setMode(mode: .view)
        self.delegate?.switchToMode(self.mode, inGSButtonVC: self)
    }
    
    @IBAction func addBtnAction(_ sender: Any) {
        self.delegate?.addBtnActionInGSButtonVC(addBtn: self.addBtn, GSBtnVC: self)
    }
    
    @IBAction func clearBtnAction(_ sender: Any) {
        self.delegate?.clearBtnActionInGSButtonVC(GSBtnVC: self)
    }
    
    @IBAction func configBtnAction(_ sender: Any) {
        self.delegate?.configBtnActionInGSButtonVC(GSBtnVC: self)
    }
    
    @IBAction func startBtnAction(_ sender: Any) {
        self.delegate?.startBtnActionInGSButtonVC(GSBtnVC: self)
    }
    
    @IBAction func stopBtnAction(_ sender: Any) {
        self.delegate?.stopBtnActionInGSButtonVC(GSBtnVC: self)
    }
    
    @IBAction func editBtnAction(_ sender: Any) {
        self.setMode(mode: .edit)
        self.delegate?.switchToMode(self.mode, inGSButtonVC: self)
    }
    
    @IBAction func focusBtnAction(_ sender: Any) {
        self.delegate?.focusBtnActionInGSButtonVC(GSBtnVC: self)
    }
}
