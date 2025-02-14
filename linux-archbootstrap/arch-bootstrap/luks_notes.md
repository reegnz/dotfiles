# EndevourOS enroll TPM2 luks decryption on boot

Make sure you have installed with full disk encryption. Calamares encrypts with
LUKS1. You need to convert to LUKS2 to be able to use TPM.


Then convert LUKS1 to LUKS2:

```sh
cryptsetup convert --type luks2 /dev/disk/by-uuid/xxxxxx
```

Install `tpm2-tss` and `tpm2-tools`


To remove existing tpm2 enrollment:

```sh
sudo systemd-cryptenroll --wipe-slot=tpm2 --crypto_keyfile /crypto_keyfile.bin /dev/disk/by-uuid/xxxxxx
```

To enroll tpm2 with PIN:

```sh
sudo systemd-cryptenroll --tpm2-device=auto \
--wipe-slot=tpm2 --tpm2-pcrs=0+2+4+7 --tpm2-with-pin=true \
--unlock-key-file /crypto_keyfile.bin
/dev/disk/by-uuid/xxxxxx
```

Dump luks keys info:

```sh
sudo cryptsetup luksDump /dev/disk/by-uuid/xxxxxx
```

Check if disk can be decrypted with tpm2 (should not prompt for passphrase):

```sh
sudo cryptsetup luksOpen -v --test-passphrase --key-slot=2 /dev/disk/by-uuid/xxxxxx
```

Testing your crypto_keyfile (used for system automation, lives in slot 0):

```sh
sudo cryptsetup luksOpen -v --test-passphrase --key-slot=0  /dev/disk/by-uuid/xxxxxx
```

Testing your crypto_keyfile (used for system automation, lives in slot 1):

```sh
sudo cryptsetup luksOpen -v --test-passphrase --key-slot=1 --key-file /crypto_keyfile.bin /dev/disk/by-uuid/xxxxxx
```

/etc/crypttab contents (file HAS TO BE -, otherwise initramfs won't decrypt with tpm):
```
luks-xxxxxx UUID=xxxxxx - tpm2-device=auto,discard
```

Recreate initramfs with dracut:

```sh
sudo reinstall-kernels
```

If output is missing this, you configured /etc/crypttab wrong.
Dracut is grep-ing for tpm2-device inside crypttab

```sh
dracut: *** Including module: tpm2-tss ***
```
