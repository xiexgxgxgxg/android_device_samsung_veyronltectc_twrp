# prebuilt/

Place the kernel and dtb extracted from the device's **stock recovery.img** here:

```
Image.gz
dtb.img
```

They are not committed (they are stock Samsung binaries and model specific).
Use `unpackbootimg` / `mkbootimg` from the TWRP tree, or `twrpdtgen`.
