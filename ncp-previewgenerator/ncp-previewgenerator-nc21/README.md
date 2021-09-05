# Preview Generator

Nextcloud app that allows admins to pre-generate previews. The app listens to 
edit events and stores this information. Once a cron job is triggered it will
start preview generation. This means that you can better utilize your
system by pre-generating previews when your system is normally idle and thus 
putting less load on your machine when the requests are actually served.

The app does not replace on demand preview generation so if a preview is 
requested before it is pre-generated it will still be shown.

## How to install

* Install directly from within your Nextcloud from the [app store](https://apps.nextcloud.com/apps/previewgenerator)
* Clone this repository in you Nextcloud app folder

## How to use the app

1. Install the app
2. Enable the app
3. Run `./occ preview:generate-all` once after installation.
4. Add a (system) cron job for ` ./occ preview:pre-generate`
  * I run it every 10 minutes

## Known issues

* The app does not work with encryption enabled

## How does the app work

1. Listen to events that a file has been written or modified and store it in the database
2. On cron run request previews for the files that have been written or modified

If a preview already exists at step 2 then requesting it is really cheap. If not
it will be generated. Depending on the sizes of the files and the hardware you
are running on the time this takes can vary.

## Commands

### preview:delete_old

This removes the previews from the old preview location that was used before
Nextcloud 11. That has some issues. Note that the gallery shipped with Nextcloud
11 did not yet use this location. So you might want to run it again with Nextcloud 12.

### preview:generate-all [user-id]

Loop over all files and try to generate previews for them. If `user-id` is supplied
just loop over the files for that user.

### preview:pre-generate

Do the actual pregeneration. This means only for new or modified files (since
the app was enabled or the last pregeneration was done).

## FAQ

### Why can't I use webcron?

Preview generation can be a very long running job. Thus we need a system that
does not time out.

### It sometimes crashed

Yes this happens. Most of it is due to corrupted files not being handled that gracefully
in the Nextcloud server. Improvements in this area are coming with Nextcloud 12

### I get "Command already running"

Yes this happens when the `pre-generate` command crashes. No worries the lock
will be released after 30 minutes of inactivity from the app. So go grab a cookie.

### I don't want to generate all the preview sizes

This is possible since version 1.0.8. Just set the correct values via the command line

```
./occ config:app:set --value="32 64 1024"  previewgenerator squareSizes
./occ config:app:set --value="64 128 1024" previewgenerator widthSizes
./occ config:app:set --value="64 256 1024" previewgenerator heightSizes
```

This will only generate:
 * square previews of: 32x32, 64x64 and 1024x1024
 * aspect ratio previews with a width of: 64, 128 and 1024
 * aspect ratio previews with a height of: 64, 256 and 1024

Note:
 * preview sizes are always a power of 2.
 * The smallest size is 32
 * The max size is determined by your preview settings in config.php
 
 ### I get  "PHP Fatal error:  Allowed memory size of X bytes exhausted"
 You need to increase the memory allowance of PHP, by default it is 128 MB. You do that by changing the memory_limit in the php.ini file.
 
 If you use the docker container you need to create the php.ini file in /usr/local/etc/php first.
