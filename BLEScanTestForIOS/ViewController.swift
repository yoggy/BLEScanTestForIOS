import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate {

    @IBOutlet weak var buttonStart: UIButton!
    @IBOutlet weak var buttonStop: UIButton!
    @IBOutlet weak var textMessage: UILabel!
    
    var labelSize : CGRect!
    
    var centralManager: CBCentralManager!
    var deviceNames: [String: Bool] = [:]

    var messages : Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textMessage.numberOfLines = 0
        textMessage.lineBreakMode = NSLineBreakMode.byCharWrapping
        labelSize = textMessage.frame;

        message("viewDidLoad()");
        updateUI(false)
        
        let options: Dictionary = [
            CBCentralManagerOptionRestoreIdentifierKey: "BLEScanTestForIOS"
        ]
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main, options: options)
    }

    override func viewDidAppear(_ animated: Bool) {
        message("viewDidAppear()");
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        message("viewWillDisappear()");
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        message("didReceiveMemoryWarning()");
    }

    /////////////////////////////////////////////////////////////////////////////
    
    @IBAction func onButtonStartTouchDown(_ sender: Any) {
        message("onButtonStartTouchDown()");
        bleStartScan()
    }
    
    @IBAction func onButtonStopTouchDown(_ sender: Any) {
        message("onButtonStopTouchDown()");
        bleStopScan()
    }

    /////////////////////////////////////////////////////////////////////////////

    func updateUI(_ flag:Bool) {
        buttonStart.isEnabled = !flag
        buttonStop.isEnabled = flag
    }
    
    func bleStartScan() {
        message("bleStartScan")
        centralManager.scanForPeripherals(
            withServices: [CBUUID(string: "b3b36901-50d3-4044-808d-50835b13a6cd")],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey : true]
        )
        updateUI(true)
    }
    
    func bleStopScan() {
        message("bleStopScan")
        centralManager.stopScan()
        updateUI(false)
        
        deviceNames.removeAll()
    }
    
    func bleRestartScan() {
        message("bleRestartScan")

        // clear flag
        deviceNames.keys.forEach { key in
            deviceNames[key] = false
        }
        
        centralManager.stopScan()

        centralManager.scanForPeripherals(
            withServices: [CBUUID(string: "b3b36901-50d3-4044-808d-50835b13a6cd")],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey : true]
        )
    }

    func checkDeviceFlags() -> Bool {
        var count = 0;
        var msg = "checkDeviceFlags() : deviceNames:"
        deviceNames.keys.forEach { key in
            msg += "\(key)=\(deviceNames[key] ?? false), "
            if deviceNames[key] == true {
                count += 1
            }
        }
        if (count == deviceNames.count) {
            msg += "return true"
            message(msg)
            return true
        }
        
        msg += "return false"
        message(msg)

        return false
    }
    
    /////////////////////////////////////////////////////////////////////////////

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        message("centralManagerDidUpdateState")
        printCentralState(central)
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let kCBAdvDataLocalName = advertisementData["kCBAdvDataLocalName"] as? String else {
            return;
        }

        let state: UIApplicationState = UIApplication.shared.applicationState
        message("centralManager:didDiscover: name:\(kCBAdvDataLocalName), RSSI:\(RSSI), state=\(state.rawValue)")
        
        if state == .active {
            // append device names...
            deviceNames[kCBAdvDataLocalName] = false
        }
        else {
            deviceNames[kCBAdvDataLocalName] = true
            
            if (checkDeviceFlags() == true) {
                bleRestartScan()
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                                 willRestoreState dict: [String : Any]) {
        message("centralManager:willRestoreState : central.state=\(central.state.rawValue)")
        self.centralManager = central
    }

    /////////////////////////////////////////////////////////////////////////////

    func printCentralState(_ central:CBCentralManager) {
        switch (central.state) {
        case .poweredOff:
            message("central.state = .poweredOff")
        case .poweredOn:
            message("central.state = .poweredOn")
        case .resetting:
            message("central.state = .resetting")
        case .unauthorized:
            message("central.state = .unauthorized")
        case .unknown:
            message("central.state = .unknown")
        case .unsupported:
            message("central.state = .unsupported")
        }
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
