import App from 'resource:///com/github/Aylur/ags/app.js';
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import Variable from 'resource:///com/github/Aylur/ags/variable.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';
import Gtk from 'gi://Gtk?version=3.0';
import Gdk from 'gi://Gdk?version=3.0';

// Translation dictionary for readable layout names, I don't know a way to do it better...
const layoutNames = {
    "US": "English",
    "RU": "Russian",
    "UA": "Ukrainian",
    "GB": "English",
    "DE": "German",
    "FR": "French",
    "ES": "Spanish",
    "IT": "Italian",
    "PL": "Polish",
    "PT": "Portuguese",
    "BR": "Portuguese",
    "TR": "Turkish",
    "BY": "Belarusian",
    "KZ": "Kazakh",
    "CN": "Chinese",
    "JP": "Japanese",
    "KR": "Korean",
    "SE": "Swedish",
    "FI": "Finnish",
    "NO": "Norwegian",
    "DK": "Danish",
    "NL": "Dutch",
    "CZ": "Czech",
    "SK": "Slovak",
    "HU": "Hungarian",
    "RO": "Romanian",
    "BG": "Bulgarian",
    "GR": "Greek",
    "IL": "Hebrew",
    "AR": "Arabic",
    "IN": "Hindi",
    "TH": "Thai",
    "VN": "Vietnamese",
    "CH": "Swiss",
    "CA": "English",
    "EE": "Estonian",
    "LV": "Latvian",
    "LT": "Lithuanian",
    "GE": "Georgian",
    "AM": "Armenian",
    "RS": "Serbian",
    "HR": "Croatian",
    "SI": "Slovenian",
    "BA": "Bosnian",
    "ME": "Montenegrin",
    "MK": "Macedonian",
    "AL": "Albanian",
    "IR": "Persian",
    "AF": "Afghan",
    "PK": "Urdu",
    "BD": "Bengali",
    "LK": "Sinhala",
    "MM": "Burmese",
    "KH": "Khmer",
    "LA": "Lao",
    "ID": "Indonesian",
    "MY": "Malay",
    "PH": "Filipino",
    "MN": "Mongolian",
    "TJ": "Tajik",
    "UZ": "Uzbek",
    "TM": "Turkmen",
    "KG": "Kyrgyz",
    "AZ": "Azerbaijani",
    "SY": "Syriac",
    "IQ": "Kurdish",
    "ZA": "Afrikaans",
    "ET": "Amharic",
    "KE": "Swahili",
    "IS": "Icelandic",
    "FO": "Faroese",
    "IE": "Irish",
    "MT": "Maltese",
    "BE": "Belgian",
    "AT": "German",
    "AU": "English",
    "NZ": "English"
};

// One-time synchronous execution to fetch available system layouts
const languageList = Utils.exec('xkb-switch -l').split('\n').filter(l => l.length > 0);

// Reactive variable tracking asynchronous layout changes
const languageStatus = Variable(
    Utils.exec('xkb-switch').toUpperCase(), 
    {
        listen: [
            'xkb-switch -W',
            (out) => out.toUpperCase()
        ]
    }
);

let hideTimeout = null;
let lastRenderedLang = languageStatus.value;
let lastWindowId = "";

// Initial window tracking to prevent focus-clash on startup
try {
    lastWindowId = Utils.exec('xdotool getactivewindow');
} catch (e) {
    lastWindowId = "desktop";
}

const OsdWindow = () => Widget.Window({
    name: 'language-osd',
    visible: false, 
    
    setup: (self) => {
        self.set_app_paintable(true);
        const screen = self.get_screen();
        const visual = screen.get_rgba_visual();
        if (visual) {
            self.set_visual(visual);
        }

        // Low-level X11 Window Manager bypass
        self.set_decorated(false);
        self.set_accept_focus(false);
        self.set_keep_above(true);
        self.set_skip_taskbar_hint(true);
        self.set_skip_pager_hint(true);
        self.set_type_hint(Gdk.WindowTypeHint.NOTIFICATION);
        
        self.connect('realize', () => {
            self.get_window().set_override_redirect(true);
        });

        // Dynamic geometry allocation hook
        self.connect('size-allocate', (widget, allocation) => {
            const display = Gdk.Display.get_default();
            const monitor = display.get_primary_monitor() || display.get_monitor(0);
            const workarea = monitor.get_workarea(); 

            const marginSide = 50; 
            const y = Math.floor(workarea.y + (workarea.height - allocation.height) / 2);
            const x = Math.floor(workarea.x + workarea.width - allocation.width - marginSide);

            widget.move(x, y);
        });

        // Main lifecycle logic hook
        self.hook(languageStatus, () => {
            const currentLang = languageStatus.value;
            let currentWindowId = "";
            
            try {
                currentWindowId = Utils.exec('xdotool getactivewindow');
            } catch (e) {
                currentWindowId = "desktop";
            }

            if (currentWindowId !== lastWindowId) {
                lastWindowId = currentWindowId;
                lastRenderedLang = currentLang;
                return;
            }

            if (currentLang === lastRenderedLang && !self.visible) {
                return;
            }

            lastRenderedLang = currentLang;
            self.visible = true;

            if (hideTimeout !== null) {
                clearTimeout(hideTimeout);
            }

            hideTimeout = setTimeout(() => {
                self.visible = false;
                hideTimeout = null;
            }, 1500);
        });
    },

    child: Widget.Box({
        className: 'osd-container-lang',
        vertical: true, // Forces items to stack vertically into a column
        children: languageList.map((i) => {
            const upperKey = i.toUpperCase();
            const displayName = layoutNames[upperKey] || upperKey; // Fallback to raw code if dictionary match fails
            
            return Widget.Label({
                label: displayName,
                className: languageStatus.bind().as(currentStatus => {
                    return upperKey === currentStatus ? "osd-lang-active" : "osd-lang";
                })
            });
        })
    })
});

const osd = OsdWindow();
// osd.show_all();
// Utils.timeout(500, () => osd.visible = false);

App.config({
    style: './style.css',
    windows: [ osd ],
});