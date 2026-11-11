
import QtQuick

QtObject {
    readonly property string name: "Modern Light"

    readonly property var colors: ({
        // Main surfaces
        background: "#F4F7FB",
        sidebarTop: "#FFFFFF",
        sidebarBottom: "#F8FAFD",
        card: "#FFFFFF",
        hover: "#EDF4FA",
        border: "#E2E8F0",

        // Text colors
        textPrimary: "#1E293B",
        textSecondary: "#64748B",

        // Accent colors
        accentBlue: "#3B82F6",
        accentGreen: "#10B981",
        accentRed: "#EF4444",
        accentOrange: "#F59E0B",
        accentPurple: "#8B5CF6"
    })
}

