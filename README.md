# docker-obs-ndi-novnc
Run OBS Studio in Docker with NDI support and webbased GUI

This is a basic setup. In the config folder you find the OBS config file. Just replace them to what ever your needs are.


### Arguments:
#### -e SCENE="xxx" loads the scene of that name.
In the build example there are two scenes:
* -e SCENE="Reciever"
* -e SCENE="Html"

#### -e URL="https://google.com" 
Replaces the name REPLACE_URL in the Untitled.json OBS config file. So you can have different URL names.

Port 4455 is also open so it's easy to control OBS from e.g. Superfly's Supertimeline.

### NDI support:
NDI is inables in and out. That's the main resason for running the container in privileged mode. So if you're not usind NDI you should turn that of when running the container.

### Build and Run:
To build the container:
```
sudo docker build . -t small-novnc
```

To run the container: (the same as the script in docker-run.sh)
```
sudo docker run -it --privileged -p 6919:6919 -p 4455:4455 -p 5959-5980:5959-5980 -p 5900-5901:5900-5901 --gpus all -v /var/run/dbus:/var/run/dbus -t -e URL="https://google.com" -e SCENE="Html" small-novnc
```

### Open GUI:
The webgui can be accessed here:
```
http://localhost:6919
```

Feel free to improve and PR'

Enjoy 😊