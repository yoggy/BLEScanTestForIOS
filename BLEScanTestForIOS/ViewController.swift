import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate {

    @IBOutlet weak var buttonStart: UIButton!
    @IBOutlet weak var buttonStop: UIButton!
    @IBOutlet weak var textMessage: UILabel!
    
    var labelSize : CGRect!
    
    var centralManager: CBCentralManager!
    
    var messages : Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textMessage.numberOfLines = 0
        textMessage.lineBreakMode = NSLineBreakMode.byCharWrapping
        labelSize = textMessage.frame;
        
        updateUI(false)
        
        let options: Dictionary = [
            CBCentralManagerOptionRestoreIdentifierKey: "BLEScanTestForIOS"
        ]
        centralManager = CBCentralManager(delegate: self, queue: nil, options: options)
    }

    override func viewWillDisappear(_ animated: Bool) {
        if (centralManager.isScanning == true) {
            centralManager.stopScan();
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func onButtonStartTouchDown(_ sender: Any) {
        
        centralManager.scanForPeripherals(
            withServices: [CBUUID(string: "b3b36901-50d3-4044-808d-50835b13a6cd")],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey : true]
        )
        updateUI(true)
    }
    
    @IBAction func onButtonStopTouchDown(_ sender: Any) {
        updateUI(false)
        
        centralManager.stopScan()
    }

    func updateUI(_ flag:Bool) {
        buttonStart.isEnabled = !flag
        buttonStop.isEnabled = flag
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch (central.state) {
        case .poweredOff:
            message("centralManagerDidUpdateState : central.state = .poweredOff")
        case .poweredOn:
            message("centralManagerDidUpdateState : central.state = .poweredOn")
        case .resetting:
            message("centralManagerDidUpdateState : central.state = .resetting")
        case .unauthorized:
            message("centralManagerDidUpdateState : central.state = .unauthorized")
        case .unknown:
            message("centralManagerDidUpdateState : central.state = .unknown")
        case .unsupported:
            message("centralManagerDidUpdateState : central.state = .unsupported")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        message("centralManager:didDiscover: peripheral:\(peripheral), RSSI:\(RSSI)")
    }
    
    func centralManager(_ central: CBCentralManager,
                                 willRestoreState dict: [String : Any]) {
        message("centralManager:willRestoreState")
    }

    func message(_ msg:String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss : "
        let now = Date()
        let date_str = formatter.string(from: now)
        
        
        print(date_str + msg)
        
        messages.append(date_str + msg)
        if messages.count > 10 {
            messages.removeFirst()
        }
        
        var str = ""
        messages.forEach { s in
            str += s
            str += "\n"
        }
        
        textMessage.text = str
        textMessage.frame = labelSize;
        textMessage.sizeToFit()
    }
}

