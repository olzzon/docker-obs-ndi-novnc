# docker-obs-ndi-novnc
Run OBS Studio in Docker with NDI support and webbased GUI

This is a basic setup. In the config folder you find the OBS config file. Just replace them to what ever your needs are.
the -e SCENE="xxx" loads the scene of that name.
the -e URL="https://google.com" replaces the name REPLACE_URL in the Untitled.json OBS config file.

To build the container:
```
sudo docker build . -t small-novnc
```

To run the container: (the same as the script in docker-run.sh)
```
sudo docker run -it --privileged -p 6919:6919 -p 4455:4455 -p 5959-5980:5959-5980 -p 5900-5901:5900-5901 --gpus all -v /var/run/dbus:/var/run/dbus -t -e URL="https://google.com" -e SCENE="Html" small-novnc
```

Feel free to improve and PR'

Enjoy 😊