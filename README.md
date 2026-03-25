# switch-monitor-linux-shell
## allow execute permissions
```
sudo chmod +x switch-monitor.sh
```

## for single monitor
```
./switch-monitor.sh && setSingleMonitor
```

## for mirror/duplicate monitor
```
./switch-monitor.sh && setMirrorMonitor
```

## for single join/extends monitor
>> right
```
./switch-monitor.sh && setJoinMonitor right
```
>> left
```
./switch-monitor.sh && setJoinMonitor left
```
