
pragma Singleton
import QtQuick

/*!
    \qmlsingletontype Theme
    \inqmlmodule Dashboard
    \since 1.0
    \brief Provides shared dashboard colors and theme selection.

    Theme is a QML singleton that exposes the active palette and supports
    registering and selecting custom themes.
*/

QtObject {
    id: themeManager

    // =====================================================
    // THEME SELECTION
    // =====================================================

    // Default theme: Cyberpunk (index 4)
    property int currentThemeIndex: 4

    // =====================================================
    // BUILT-IN THEME NAMES
    // =====================================================

    readonly property var themeNames: [
        "Dark Blue Purple",
        "Purple Branding",
        "Ocean Breeze",
        "Nord Dark",
        "Cyberpunk",
        "Forest"
    ]

    // =====================================================
    // BUILT-IN COLOR PALETTES
    // =====================================================

    readonly property var palettes: [
        ({
            background: "#1a1a2e",
            sidebarTop: "#1e1e2e",
            sidebarBottom: "#252537",
            card: "#242437",
            hover: "#2d2d3f",
            border: "#2a2a3e",
            textPrimary: "#ffffff",
            textSecondary: "#b8b8c8",
            accentBlue: "#3498db",
            accentGreen: "#2ecc71",
            accentRed: "#e74c3c",
            accentOrange: "#f39c12",
            accentPurple: "#9b59b6"
        }),

        ({
            background: "#1a1625",
            sidebarTop: "#221833",
            sidebarBottom: "#2a1f3d",
            card: "#2a1f3d",
            hover: "#3d2656",
            border: "#2e2440",
            textPrimary: "#ffffff",
            textSecondary: "#c4b8d8",
            accentBlue: "#9b59b6",
            accentGreen: "#00bcd4",
            accentRed: "#e91e63",
            accentOrange: "#ff9800",
            accentPurple: "#9b59b6"
        }),

        ({
            background: "#0d1b2a",
            sidebarTop: "#1b263b",
            sidebarBottom: "#243447",
            card: "#1f2d3d",
            hover: "#2d3e50",
            border: "#2c3e50",
            textPrimary: "#e0f4ff",
            textSecondary: "#a8d8ea",
            accentBlue: "#00b4d8",
            accentGreen: "#06ffa5",
            accentRed: "#ff6b9d",
            accentOrange: "#ffaa00",
            accentPurple: "#c77dff"
        }),

        ({
            background: "#2e3440",
            sidebarTop: "#3b4252",
            sidebarBottom: "#434c5e",
            card: "#3b4252",
            hover: "#434c5e",
            border: "#4c566a",
            textPrimary: "#eceff4",
            textSecondary: "#d8dee9",
            accentBlue: "#81a1c1",
            accentGreen: "#a3be8c",
            accentRed: "#bf616a",
            accentOrange: "#d08770",
            accentPurple: "#b48ead"
        }),

        ({
            background: "#0a0e27",
            sidebarTop: "#1a1a2e",
            sidebarBottom: "#16213e",
            card: "#1a1a2e",
            hover: "#2d2d3f",
            border: "#4a148c",
            textPrimary: "#ffffff",
            textSecondary: "#b0b0d0",
            accentBlue: "#00d9ff",
            accentGreen: "#39ff14",
            accentRed: "#ff0080",
            accentOrange: "#ffcc00",
            accentPurple: "#bd00ff"
        }),

        ({
            background: "#1a2421",
            sidebarTop: "#233329",
            sidebarBottom: "#2d3e37",
            card: "#2a3d34",
            hover: "#3a4f44",
            border: "#3d5a4c",
            textPrimary: "#e8f5e9",
            textSecondary: "#a5d6a7",
            accentBlue: "#4dd0e1",
            accentGreen: "#66bb6a",
            accentRed: "#ef5350",
            accentOrange: "#ffa726",
            accentPurple: "#7e57c2"
        })
    ]

    // =====================================================
    // CUSTOM THEMES
    // =====================================================

    // Each item:
    // {
    //     name: "Theme Name",
    //     colors: { ... }
    // }

    property var customThemes: []

    // =====================================================
    // ALL AVAILABLE THEMES
    // =====================================================

    readonly property var allThemeNames:
        themeNames.concat(
            customThemes.map(function(theme) {
                return theme.name
            })
        )

    readonly property var allPalettes:
        palettes.concat(
            customThemes.map(function(theme) {
                return theme.colors
            })
        )

    // =====================================================
    // ACTIVE THEME
    // =====================================================

    readonly property var activeTheme:
        allPalettes[currentThemeIndex] || palettes[4]

    readonly property string currentThemeName:
        allThemeNames[currentThemeIndex] || themeNames[4]

    // =====================================================
    // THEME COLORS
    // =====================================================

    property color background: activeTheme.background
    property color sidebarTop: activeTheme.sidebarTop
    property color sidebarBottom: activeTheme.sidebarBottom
    property color card: activeTheme.card
    property color hover: activeTheme.hover
    property color border: activeTheme.border

    property color textPrimary: activeTheme.textPrimary
    property color textSecondary: activeTheme.textSecondary

    property color accentBlue: activeTheme.accentBlue
    property color accentGreen: activeTheme.accentGreen
    property color accentRed: activeTheme.accentRed
    property color accentOrange: activeTheme.accentOrange
    property color accentPurple: activeTheme.accentPurple

    // Font
    property string fontFamily: "Segoe UI"

    // =====================================================
    // REQUIRED COLOR KEYS
    // =====================================================

    readonly property var requiredColorKeys: [
        "background",
        "sidebarTop",
        "sidebarBottom",
        "card",
        "hover",
        "border",
        "textPrimary",
        "textSecondary",
        "accentBlue",
        "accentGreen",
        "accentRed",
        "accentOrange",
        "accentPurple"
    ]

    // =====================================================
    // REGISTER CUSTOM THEME
    // =====================================================

    function registerTheme(name, colors) {

        if (typeof name !== "string" || !name.trim()) {
            console.warn("Theme: Invalid theme name")
            return false
        }

        if (!colors || typeof colors !== "object") {
            console.warn("Theme: Invalid colors object")
            return false
        }

        const cleanName = name.trim()

        // Check duplicate names
        if (allThemeNames.indexOf(cleanName) !== -1) {
            console.warn("Theme: Theme name already exists:", cleanName)
            return false
        }

        // Validate required colors
        for (let i = 0; i < requiredColorKeys.length; i++) {

            const key = requiredColorKeys[i]
            const value = colors[key]

            if (typeof value !== "string" ||
                !/^#[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$/.test(value)) {

                console.warn("Theme: Invalid or missing color:", key)
                return false
            }
        }

        // Copy colors to prevent external mutation
        const copiedColors = {}

        for (let i = 0; i < requiredColorKeys.length; i++) {
            const key = requiredColorKeys[i]
            copiedColors[key] = colors[key]
        }

        // Create updated array
        const updatedThemes = customThemes.slice()

        updatedThemes.push({
            name: cleanName,
            colors: copiedColors
        })

        // Reassign property to notify QML bindings
        customThemes = updatedThemes

        console.log("Theme registered successfully:", cleanName)

        return true
    }

    // =====================================================
    // SELECT THEME BY NAME
    // =====================================================

    function setTheme(name) {

        const index = allThemeNames.indexOf(name)

        if (index === -1) {
            console.warn("Theme not found:", name)
            return false
        }

        currentThemeIndex = index

        console.log("Theme changed to:", name)

        return true
    }

    // =====================================================
    // SELECT THEME BY INDEX
    // =====================================================

    function setThemeByIndex(index) {

        if (index < 0 || index >= allThemeNames.length)
            return false

        currentThemeIndex = index
        return true
    }

    // =====================================================
    // CHECK IF THEME IS CUSTOM
    // =====================================================

    function isCustomTheme(name) {
        return customThemes.some(function(theme) {
            return theme.name === name
        })
    }
}
