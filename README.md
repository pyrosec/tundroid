# tundroid

Make Android phone accessible from a public server via reverse SSH tunnel. Useful for building DIY 4g/5g proxies, or any purpose related to remote administration of an Android device.

## Usage

Use the build-shar.sh script to specify a host with the `-c` switch which the Android device should connect to on the port specified by `-p` (defaults 22) and expose its own localhost:8022 (8022 can be replaced with the `-R` switch) on that host. The RSA key specified with the `-i` flag will be packed into the shar so it is best to generate a new key for this. The `authorized_keys` file on the Android device can be supplied with the `-a` flag (defaults to `~/.ssh/id_rsa.pub`)

```sh
bash ./build-shar.sh -c mydomain.dns.army -i ~/.ssh/id_rsa -a ~/.ssh/authorized_keys
```

This command will create a `tundroid.shar` file in the current working directory. Install Termux and Termux:Boot on an Android device then get the shar file on the device by some means. On the Android device run the command `sh ./tundroid.shar` and the device will be set up to automatically tunnel to the server specified when you built the shar file.


## License

MIT
