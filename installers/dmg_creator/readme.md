Make sure appdmg is installed, if not run ```npm install -g appdmg```
Then run following commands:
```
flutter build macos
appdmg ./dmg_creator/config.json ./dmg_creator/blackhole.dmg
```