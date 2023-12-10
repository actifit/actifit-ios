//
//  TrackMeasurementsCell.swift
//  Actifit
//
//  Created by Ali Jaber on 20/10/2023.
//

import UIKit

protocol TrackMeasurementCellDelegate: AnyObject {
    func measurementsDidChange(_ text: [String: String?]?, in cell: TrackMeasurementsCell)
}

class TrackMeasurementsCell: UITableViewCell, UITextFieldDelegate {
    var measurements: [String: String]? {
        didSet {
            fillMeasurements()
        }
    }
    @IBOutlet weak var heightUnitLabel: UILabel!
    
    @IBOutlet weak var chestUnitLabel: UILabel!
    @IBOutlet weak var weightUnitLabel: UILabel!
    
    @IBOutlet weak var heightTextField: AFTextField!
    
    @IBOutlet weak var thighsUnitLabel: UILabel!
    @IBOutlet weak var waistUnitLabel: UILabel!
    
    @IBOutlet weak var chestTextField: AFTextField!
    @IBOutlet weak var thighsTextField: AFTextField!
    @IBOutlet weak var waistTextField: AFTextField!
    @IBOutlet weak var bodyFatTextField: AFTextField!
    @IBOutlet weak var weightTextField: AFTextField!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var numberView: UIView!
    weak var measurementDelegate: TrackMeasurementCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        numberView.layer.cornerRadius = numberView.frame.width / 2
        numberView.layer.borderWidth = 3
        numberView.layer.borderColor = UIColor.primaryGreenColor().cgColor
        
        chestTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        thighsTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        waistTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        bodyFatTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        weightTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        heightTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        showMeasurementUnits()
        // Initialization code
    }
    
    private func fillMeasurements() {
        guard let measurement = measurements else {return}
        measurement.forEach { element in
            switch element.key {
            case PostKeys.height: heightTextField.text = element.value
            case PostKeys.chest: chestTextField.text = element.value
            case PostKeys.waist: waistTextField.text = element.value
            case PostKeys.thigs: thighsTextField.text = element.value
            case PostKeys.weight: weightTextField.text = element.value
            default: break;
                
            }
        }
    }
    
    func showMeasurementUnits() {
        var measurementSystem = MeasurementSystem.metric.rawValue
        if let settings = Settings.current() {
            measurementSystem = settings.measurementSystem
        }
        weightUnitLabel.text = measurementSystem == MeasurementSystem.metric.rawValue ? MeasurementUnit.metric.kg : MeasurementUnit.us.lb
        heightUnitLabel.text = measurementSystem == MeasurementSystem.metric.rawValue ? MeasurementUnit.metric.cm : MeasurementUnit.us.ft
        chestUnitLabel.text = measurementSystem == MeasurementSystem.metric.rawValue ? MeasurementUnit.metric.cm : MeasurementUnit.us.inch
        waistUnitLabel.text = measurementSystem == MeasurementSystem.metric.rawValue ? MeasurementUnit.metric.cm : MeasurementUnit.us.inch
        thighsUnitLabel.text = measurementSystem == MeasurementSystem.metric.rawValue ? MeasurementUnit.metric.cm : MeasurementUnit.us.inch
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        switch textField {
        case heightTextField:
            measurementDelegate?.measurementsDidChange([PostKeys.height: "\(heightTextField.text ?? "")"], in: self)
        case thighsTextField: measurementDelegate?.measurementsDidChange([PostKeys.thigs: "\(thighsTextField.text ?? "")"], in: self)
        case chestTextField: measurementDelegate?.measurementsDidChange([PostKeys.chest: "\(chestTextField.text ?? "")"], in: self)
        case waistTextField: measurementDelegate?.measurementsDidChange([PostKeys.waist:"\(waistTextField.text ?? "")"], in: self)
        case bodyFatTextField: measurementDelegate?.measurementsDidChange([PostKeys.bodyfat: "\(bodyFatTextField.text ?? "") "], in: self)
        case weightTextField: measurementDelegate?.measurementsDidChange([PostKeys.weight: "\(weightTextField.text ?? "")"], in: self)
        default: break
        }
       
       }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
