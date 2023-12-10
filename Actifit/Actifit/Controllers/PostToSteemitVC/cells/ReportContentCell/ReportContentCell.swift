//
//  ReportContentCell.swift
//  Actifit
//
//  Created by Ali Jaber on 25/10/2023.
//

import UIKit
import Down
class ReportContentCell: UITableViewCell, UITextViewDelegate {
    
    var imageUpdates: String? {
        didSet{
            updateImages()
        }
    }
    @IBOutlet weak var imagePickerBtnView: UIView!
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var mardDownView: UIView!
    var randomHints = ["Describe your day's activity using original content in as little as a few sentences. The more the merrier!","What did you do today?", "Got some cool content to share?", "The more original content you write, the better the potential rewards!", "Did you cross some milestones today? tell the world about it!", "How's your fitness journey going? share it with other actifitters", "You got cool pics from your walk/jog/workout/...? Let's go"]
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var videoBtn: UIButton!
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var numberView: UIView!
    @IBOutlet weak var previewContentTextField: AFTextView!
    @IBOutlet weak var imagePickerBtn: UIButton!
    var onOpenAlbumTapped:(() ->())?
    var onInfoBtnTapped:(() ->())?
    override func awakeFromNib() {
        super.awakeFromNib()
        infoBtn.layer.cornerRadius = infoBtn.frame.width / 2
        infoBtn.clipsToBounds = true
        imagePickerBtn.layer.cornerRadius = 2
        imagePickerBtn.clipsToBounds = true
        videoBtn.layer.cornerRadius = 2
        videoBtn.clipsToBounds = true
        numberView.layer.cornerRadius = numberView.frame.width / 2
        numberView.layer.borderWidth = 3
        numberView.layer.borderColor = UIColor.primaryGreenColor().cgColor
        
      
       
        previewContentTextField.delegate = self
        refreshCell()
      
      
        // Initialization code
    }
    
    private func updateImages() {
        guard let updatedContent = imageUpdates else { return }
        previewContentTextField.text = updatedContent
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.updateMarkDownView()
        })
        
    }
    
    private func refreshCell() {
        let content = UserDefaults.standard.string(forKey: "postcontent")
        previewContentTextField.text = content
        countLabel.text = "\(previewContentTextField.text.count)"
        if previewContentTextField.text.count != 0 {
            previewContentTextField.textColor = .black
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
                self.updateMarkDownView()
            })
        } else {
            previewContentTextField.textColor = .darkGray
            previewContentTextField.text = randomHints[Int.random(in: 0..<randomHints.count)]
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func infoBtnTapped(_ sender: Any) {
        onInfoBtnTapped?()
    }
    
    @IBAction func imagePickerBtnTapped(_ sender: Any) {
        onOpenAlbumTapped?()
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        if(previewContentTextField.text.count < 100) {
            numberView.layer.borderColor = UIColor.primaryRedColor().cgColor
            numberLabel.textColor = .primaryRedColor()
            countLabel.textColor = .primaryRedColor()
        } else {
            numberView.layer.borderColor = UIColor.primaryGreenColor().cgColor
            numberLabel.textColor = .primaryGreenColor()
            countLabel.textColor = .primaryGreenColor()
        }
        countLabel.text = "\(previewContentTextField.text.count)"
        UserDefaults.standard.set(textView.text, forKey: "postcontent")
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
       
        updateMarkDownView()
        if textView.text == "" {
            previewContentTextField.textColor = .darkGray
            textView.text = randomHints[Int.random(in: 0..<randomHints.count)]
        } else {
            previewContentTextField.textColor = .black
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if randomHints.contains(textView.text) {
            textView.text = ""
        }
    }
    
    

    
    func updateMarkDownView(){
//        for view in mardDownView.subviews {
//            view.removeFromSuperview()
//        }
        guard let markDownString = previewContentTextField.text else {
            return
        }
        
        if let downView = try? DownView(frame: self.mardDownView.frame, markdownString: markDownString) {
            downView.pageZoom = 1
            mardDownView.addSubview(downView)
//            if markDownString != "" {
//                markDownEditorHeight.constant = 500
//            } else {
//                markDownEditorHeight.constant = 50
//            }
         //   mardDownView.layoutIfNeeded()

        }
        
    }
    
}
