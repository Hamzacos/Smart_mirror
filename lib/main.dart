import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wi-Fi Selector',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WiFiSelectorScreen(),
    );
  }
}

class WiFiSelectorScreen extends StatefulWidget {
  @override
  _WiFiSelectorScreenState createState() => _WiFiSelectorScreenState();
}

class _WiFiSelectorScreenState extends State<WiFiSelectorScreen> {
  List<WifiNetwork> _networks = [];
  String? _selectedSSID; // Marqué comme nullable
  String _password = '';

  @override
  void initState() {
    super.initState();
    _scanForNetworks();
  }

  void _scanForNetworks() async {
    List<WifiNetwork> networks = await WiFiForIoTPlugin.loadWifiList();
    setState(() {
      _networks = networks;
    });
  }

  void _connectToWiFi() async {
    if (_selectedSSID != null && _password.isNotEmpty) {
      bool isConnected = await WiFiForIoTPlugin.connect(
        _selectedSSID!,
        password: _password,
        joinOnce: true,
        security: NetworkSecurity.WPA,
      );
      if (isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connected to $_selectedSSID')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect to $_selectedSSID')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a network and enter a password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wi-Fi Selector'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              hint: Text('Select Wi-Fi Network'),
              value: _selectedSSID,
              onChanged: (String? value) {
                setState(() {
                  _selectedSSID = value;
                });
              },
              items: _networks.map<DropdownMenuItem<String>>((WifiNetwork network) {
                return DropdownMenuItem<String>(
                  value: network.ssid,
                  child: Text(network.ssid ?? 'Unknown SSID'),
                );
              }).toList(),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  _password = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _connectToWiFi,
              child: Text('Connect'),
            ),
          ],
        ),
      ),
    );
  }
}
