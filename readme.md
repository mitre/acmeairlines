This iOS app demonstrates a multitude of vulnerable or potentially malicious activities that trace to the NIAP Application Software Protection Profile. The app is meant to look like an electronic flight bag.  This app demonstrates:
* Access to device hardware resources (4A / NIAP FDP_DEC_EXT.1.1) and to sensitive information repositories on the device (4B / NIAP FDP_DEC_EXT.1.2). 
* Insecure writing of sensitive application data to device storage (3C / NIAP FDP_DAR_EXT.1.1 and FMT_CFG_EXT.1.2), and insecure network communication (3D / NIAP FDP_DIT_EXT.1.1, FIA_X509_EXT.1.1, FCS_TLSC_EXT.1.2, FCS_TLSC_EXT.1.3, 4C / FDP_NET_EXT.1.1). 
* Inclusion of default credentials (3E / NIAP FMT_CFG_EXT.1.1) and insecure storage of credentials (3B / NIAP FCS_STO_EXT.1.1). 
* Failure to invoke an appropriate random number generator where needed (3A / NIAP FCS_RBG_EXT.1.1) and other inappropriate cryptographic practices (3M). 
* Use of an unsupported platform API (4E / NIAP FPT_API_EXT.1.1).
* The ability for a malicious app to potentially bypass app vetting by downloading and executing new code after installation time (3J / NIAP FPT_AEX_EXT.1.4 and 4D / NIAP FPT_TUD_EXT.1.4).

At app start time, the app demonstrates it has established access to device hardware resources by attempting to activate the device microphone for 5 seconds and sending the recorded audio to a remote server. It also uses iOS APIs to attempt to gather information from sensitive information repositories on the device and send the gathered information to a remote server via HTTPS (it can also be configured to use HTTP). This information includes the names of all apps installed on the device and contact list entries.

The app additionally attempts to gather the device’s physical location (e.g., via GPS) once the user has clicked on a “Map” navigation menu and to send the location data to a remote server.

When HTTPS is used, the app deliberately disables checking of the server’s certificate and hostname, thus enabling an attacker to easily perform a man-in-the-middle attack to intercept or manipulate communication. The app also sends some data to the same server using HTTP. HTTP provides no cryptographic protection over the network, so interception or manipulation of communication is even simpler. The app deliberately disables iOS App Transport Security so that it can disable HTTPS server certificate checking and so that it can use plaintext HTTP.

The app writes various gathered data to internal storage with deliberately insecure file permissions written using NSFileProtectionNone. The app also demonstrates Uniform Resource Identifier (URI) scheme hijacking by registering URI schemes used by the Google Chrome iOS app.  This results in links from within Google apps to open in the AcmeAirlines app instead of the Chrome app, which could be used by a malicious app to request credentials from a user as detailed in this article from [FireEye](https://www.fireeye.com/blog/threat-research/2015/02/ios_masque_attackre.html).

The app embeds in its code a default username and password used for HTTP Basic Authentication to the remote server. The app also writes the username and password value in the clear to a file in the app’s internal data directory. Storing cleartext passwords on the device, even in the app’s internal data directory, is generally considered poor security practice.

The app embeds in its code a default AES key used to encrypt gathered data (the data is stored locally and transmitted to the remote server both in unencrypted and encrypted form). The app does not follow cryptographic best practices for AES-CBC encryption: it uses a static initialization vector (also embedded in the code) instead of a randomly generated initialization vector, and the ciphertext is not authenticated (no MAC operation is applied to it).

As a more sophisticated test of the ability of vetting solutions to analyze app behavior, the app has a time-bomb that is triggered to execute seven days after installation.  After the seven days have lapsed and the user has run the app, it will gather calendar entries on the device and send them to the remote server. 

This app also demonstrates the ability for a malicious app to potentially bypass Apple’s app vetting via mobile code. The app utilizes a third party library called JSPatch to download a JavaScript “hot patch” file. The JavaScript is then converted to Objective-C code and executed using “method swizzling”. Method swizzling exploits the ability to change a method’s execution at runtime and can be used to modify an app’s behavior dynamically. The app downloads a JavaScript hot patch file that injects use of the allApplications selector from the LSApplicationWorkspace class, a private API call, to obtain a [list of apps](http://www.andreas-kurtz.de/2014/09/malicious-apps-ios8.html) installed on the device.  This demonstrates how a bad actor could use [hot patching](https://www.fireeye.com/blog/threat-research/2016/01/hot_or_not_the_bene.html) to introduce functionality that the App Store may not catch. 



