import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import Qt.labs.settings 1.0
import QtPositioning 5.9
import QtLocation 5.9

import unik.UnikQProcess 1.0

ApplicationWindow{
	id:app
    visible:true
    title: 'Mínyma by @nextsigner...'
    width: Screen.width/2
    height: Screen.desktopAvailableHeight-altoBarra
    color: 'black'
    property string moduleName: 'unikast'
    property int altoBarra: 0
    property int fs: Screen.width*0.02

    property color c1: "#62DA06"
    property color c2: "#8DF73B"
    property color c3: "black"
    property color c4: "white"

    property int uHeight: 0
    Settings{
        id: appSettings
        category: 'conf-minyma'
        property int cantRun
        property bool fullScreen
        property bool logViewVisible

        property int fs

        property int lvh

        property real visibility
    }
    FontLoader {name: "FontAwesome";source: "qrc:/fontawesome-webfont.ttf";}
    UnikQProcess{
        id: uqp
        onLogDataChanged: {
            //console.log('LogData: '+logData)
            let ip=(''+logData).replace(/ /g, '').replace(/\n/g, '')
            console.log('UnikWebSocketServerView IP: '+ip)
            let comp=Qt.createComponent("UnikWebSocketServerView.qml")
            let obj=comp.createObject(app, {ip:ip})
            app.title='Mínyma by @nextsigner - '+ip+':'+obj.port
            //Qt.quit()
        }
        onFinished: {
        }
        onStarted: {

        }
        Component.onCompleted: {
            uqp.run('sh ./getIp.sh')
        }
    }

    //UnikWebSocketServerView{id:uwss}

    LogView{
        id:logView
        width: parent.width
        height: appSettings.lvh
        fontSize: app.fs
        topHandlerHeight: Qt.platform.os!=='android'?app.fs*0.25:app.fs*0.75
        showUnikControls: true
        anchors.bottom: parent.bottom
        visible: appSettings.logViewVisible
    }
    Component.onCompleted: {
        if(appSettings.lvh<=0){
            appSettings.lvh=100
        }
        if(appSettings.fs<=0){
            appSettings.fs=20
        }
        appSettings.logViewVisible=true

        if(Qt.platform.os==='windows'){
            var anchoBorde=(app.width-unik.frameWidth(app))/2
            var altoBarraTitulo=unik.frameHeight(app)-height
            app.altoBarra=height-(Screen.desktopAvailableHeight-altoBarraTitulo)
        }
    }
}
