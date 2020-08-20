package mapdaemon;

/**
 * Helper class to check the operating system this Java VM runs in
 */
import java.util.Locale;

public final class OSCheck {

    /**
     * Types of Operating Systems
     */
    public static enum OSType {
        Windows, MacOS, Linux, Other
    };

    // Cached result of OS detection
    protected static OSType detectedOS;

    /**
     * Detect the operating system from the os.name System property and cache
     * the result
     *
     * @returns - the operating system detected
     */
    public static OSType getOperatingSystemType() {
        if (detectedOS == null) {
            String OS = System.getProperty("os.name", "generic").toLowerCase(Locale.ENGLISH);
            if ((OS.contains("mac")) || (OS.contains("darwin"))) {
                detectedOS = OSType.MacOS;
            } else if (OS.contains("win")) {
                detectedOS = OSType.Windows;
            } else if (OS.contains("nux")) {
                detectedOS = OSType.Linux;
            } else {
                detectedOS = OSType.Other;
            }
        }
        return detectedOS;
    }
}
