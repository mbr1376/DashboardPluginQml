
import QtQuick
import Dashboard

Window {
    width: 1400
    height: 900
    minimumWidth: 1100
    minimumHeight: 700
    visible: true
    title: "Dashboard Module - Example"
    color: Theme.background

    MyTheme {
        id: companyTheme
    }

    Component.onCompleted: {
        if (Theme.registerTheme(
                companyTheme.name,
                companyTheme.colors)) {
            Theme.setTheme(companyTheme.name)
        }

        if (appSettings.hasSavedLayout)
            dashboard.setLayout(appSettings.savedLayout)
    }

    DashboardView {
        id: dashboard
        anchors.fill: parent
        dataModel: dashboardModel

        onSaveLayoutRequested: function(layout) {
            appSettings.saveLayout(layout)
        }
    }
}
