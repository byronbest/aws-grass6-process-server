# aws-grass6-process-server
Requests queued, EC2 server management, results notification and stored in S3

Upload this to /home/ec2-user; EC2 image must include patched version of GRASS6.4 in order to use r.to.vect to extract route stats and KML styled, with legend for HTML using Google Maps. Server init includes copying S3 to /home/ec2-user, and sync of S3 grassdata to the ephemeral storage.

This package was developed for and used by WECC five years ago. Verified by dozens of engineers, over entire Western Interconnect. The defect in r.to.vect has been fixed in upcoming 7.9 (finally)!
Some content is public, some data is sensitive (and hence not available here).

Interesting parts include tiling enormous images for use in Google Maps, finding least-cost routes, and summary by miles per category. KML format has changed since this, so merge.pl is broken now-- upcoming release in 7.9 fixes this and more!

Note GRASS does not support multiple segment lines with blending, nor does KML, so the line is broken into many short segments plotted end-to-end. The length is cell-center to cell-center, so is off by as much as one half a cell (RESOLUTION/2). This is mitigated by dividing the cells by five, reducing the uncertainty. The KML is solely used for user viewing.

The result segments that only have one point are the places where blending over one half grid cell would be indicated.

Website interaction sends e.g. "LINE=lon,lat,lon,lat NAME=identifier sh-script-in-bin" to process queue, AWS starts up one or more servers to handle requests one at a time, Python reads request and runs GRASS, results uploaded to S3 and notifications (pass/fail) to SNS.

Requests in queue are just shell commands; must be secure! Will do anything, including "rm -rf /" nasties!
