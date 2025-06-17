## PoatsPageBrightAdjust

As the name suggests - An extension for FF to allow page specific brightness control.
Got the idea when the other adjust brightness extension wouldn't work for all sites, as well as
being a bit chompy and not fun to work with.

* Disclaimer - In this alpha release it really is "per page" and not domain - Will fix in ToDo *

### Essentials

The content.js creates a <div> gray cover background-color rgb(dec%, dec%, dec%) with 100 % as default (white). It listens
for sendMessage of type "update-brightness" for a new level to set the value to.
The cover has attribute of massive z-index (full on frontal) and has mix-blend-mode multiply to blend as a simple
brightness decrease -> The lower the grayscale - the more the reduction of white.

popup.js uses the FF API to sendMessage to content.js with type "update-brightness" and the current level set
via slider in popup.html. A debouncer is applied in code so new levels only get set every 100 ms.

popup.html is the finest GUI you have seen with a simple slider to set levels and a checkbutton to enable/disable
dim.

### Install

To test it download all files to a folder. Open FF about:debugging#/runtime/this-firefox and load as temporary addon
from the manifest.json file.
[For private mode users you will have to Manage the extension and allow it in private]

### ToDo

* Adjust so it will be per domain and not page - Update 20250717 - Today it works without any change of code. Will still go through code and do tests
* Ensure that least necessary permissions are set
* Consider how many domains to store setting for at a time and when to do cleanup
