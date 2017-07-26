//
//  BenchmarkSettingsViewController.swift
//  esriTrial1
//
//  Created by Tushar Koul on 7/25/17.
//  Copyright © 2017 Tushar Koul. All rights reserved.
//

import UIKit
import ArcGIS

protocol BenchmarkSettingsDelegate: class {
    func settingsDidSave()
}

enum GraphicObjectKind:Int {
    case Point=0
    case Polyline
    case Polygon
}

class BenchmarkSettingsViewController: UIViewController {

    @IBOutlet private weak var objectCountTextField: UITextField!
    @IBOutlet private weak var graphicSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var batchModeSwitch: UISwitch!
    @IBOutlet private weak var rendererSwitch: UISwitch!
    @IBOutlet private weak var renderingModeSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var startButton: UIButton!
    
    weak var settingsDelegate:BenchmarkSettingsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadDefaults()
    }
    
    func loadDefaults() {
        self.objectCountTextField.text = String(BenchmarkHelper.getObjectCount())
        self.graphicSegmentedControl.selectedSegmentIndex = BenchmarkHelper.getObjectKind().rawValue
        self.batchModeSwitch.setOn(BenchmarkHelper.getBatchMode(), animated: false)
        self.rendererSwitch.setOn(BenchmarkHelper.getRendererEnabled(), animated: false)
        self.renderingModeSegmentedControl.selectedSegmentIndex = BenchmarkHelper.getRenderingMode()
    }

    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        let objectCount = Int(self.objectCountTextField.text!)!
        BenchmarkHelper.setObjectCount(count: objectCount)
        
        let objectKind = GraphicObjectKind(rawValue:self.graphicSegmentedControl.selectedSegmentIndex)!
        BenchmarkHelper.setObjectKind(kind: objectKind)
        
        let batchMode = self.batchModeSwitch.isOn
        BenchmarkHelper.setBatchMode(isBatchMode: batchMode)
        
        let rendererEnabled = self.rendererSwitch.isOn
        BenchmarkHelper.setRendererEnabled(isRendererEnabled: rendererEnabled)
        
        let renderingMode = self.renderingModeSegmentedControl.selectedSegmentIndex
        BenchmarkHelper.setRenderingMode(renderingModeVal: renderingMode)
        
        self.dismiss(animated: true) { [weak self] in
            self?.settingsDelegate?.settingsDidSave()
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}