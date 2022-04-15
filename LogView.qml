import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Styles 1.4
Rectangle{
    id:raiz
    width: parent.width
    height:  parent.height
    clip: true
    color: raiz.scrollBarBgColor
    border.width: 1
    border.color: raiz.scrollBarHandlerColor
    property string bodyText: ''
    property var handlerSB

    property bool showUnikControls: false
    property bool showUnikInitMessages: unik.debugLog
    property int fontSize:14
    property string fontFamily: 'Arial'

    property int maxLength: 1000*50*5
    property int topHandlerHeight:0
    property color handlerColor: '#ccc'
    property color fontColor: "#1fbc05"
    property color bgColor: "#000000"

    property int scrollBarWidth:12
    property color scrollBarHandlerColor: raiz.fontColor
    property color scrollBarBgColor: raiz.bgColor

    property bool showPlainText: false
    property bool enableAutoToBottom: true

    property bool showCommandsLineInput: false
    property int commandsLineInputHeight: raiz.fontSize*2

    property string help: ''


    FontLoader {name: "FontAwesome";source: "qrc:/fontawesome-webfont.ttf";}
    Connections {target: unik;onUkStdChanged: log((''+unik.ukStd).replace(/\n/g, '<br />'));}
    Connections {target: unik;onStdErrChanged: log((''+unik.ukStd).replace(/\n/g, '<br />'));}
    Timer{
        running: raiz.height<=0&&raiz.topHandlerHeight<=0
        repeat: false
        interval: 500
        onTriggered: {
            raiz.topHandlerHeight=4
            raiz.height=4
        }
    }
    Flickable{
        id:fk
        width: parent.width-fontSize*2
        height: raiz.showUnikControls ? parent.height-lineRTop.height-xBtns.height : parent.height-lineRTop.height
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        contentWidth: parent.width
        contentHeight: logTxt.height
        boundsBehavior: Flickable.StopAtBounds
        onDragStarted:  draged=true

        property bool draged: false
        property int uh:0
        property int ucy:0
        onContentYChanged: {
            if(fk.contentY>fk.contentHeight-fk.height-(fk.height/16)&&draged){
                draged=false
            }
            if(contentY!==0&&contentY<=ucy){
                draged=true
            }
            ucy=contentY
        }
        ScrollBar.vertical: ScrollBar {
            parent: fk.parent
            anchors.top: fk.top
            anchors.left: fk.right
            anchors.bottom: fk.bottom
            width: fontSize
        }
        Text {
            id: logTxt
            width: parent.width-fontSize*2
            height: contentHeight
            font.pixelSize: fontSize
            color: fontColor
            wrapMode: Text.WordWrap
            textFormat: showPlainText ? Text.Normal : Text.RichText
            onTextChanged: {
                if(!fk.draged){
                    //fk.uh=contentHeight
                }
            }
        }
    }
    LineResizeTop{
        id:lineRTop;
        width: raiz.width
        height: raiz.topHandlerHeight
        color: raiz.handlerColor
        minY: 0-raiz.y
        maxY: height
        onEnabledChanged: raiz.height+=10
        onYChanged: {
            raiz.height-=y;lineRTop.y=0;
            if(raiz.height<=raiz.topHandlerHeight){
                raiz.height=raiz.topHandlerHeight
                lineRTop.y=0;
            }
        }
        onProcesar: {
            raiz.height-=y;lineRTop.y=0;
        }
        onLineReleased: {
            raiz.height-=y;lineRTop.y=0;
            if(raiz.height<=raiz.topHandlerHeight){
                raiz.height=raiz.topHandlerHeight
                lineRTop.y=0;
            }
        }
    }
    Rectangle{
        id: xBtns
        width: raiz.width
        height: raiz.showUnikControls?raiz.fontSize*2:0
        color: raiz.fontColor
        anchors.top: lineRTop.bottom
        Row{
            visible: parent.height!==0
            anchors.right: parent.right
            anchors.rightMargin: raiz.fontSize*0.2
            anchors.verticalCenter: parent.verticalCenter
            height: raiz.fontSize*1.6
            spacing: raiz.fontSize
            Boton{
                w:parent.height
                h: w
                t: '\uf1f8'
                b: raiz.bgColor
                c: raiz.fontColor
                d:'Eliminar Todo los Objetos Remotos'
                tp:2
                z:parent.children[parent.children.length-1].z+1
                visible:uwss.container.children.length>0
                onClicking: {
                    uwss.clear()
                }
            }
            Boton{
                id:btnDown
                w:parent.height
                h: w
                t: '\uf063'
                b: raiz.bgColor
                c: raiz.fontColor
                d:'Reducir LogView hacia abajo'
                tp:1
                onClicking: {
                    raiz.height=0+lineRTop.height
                }
            }
            Boton{
                id:btnTextType
                w:parent.height
                h: w
                t: ''
                b: raiz.bgColor
                c: raiz.fontColor
                d:raiz.showPlainText?'LogView a HTML':'LogView a TXT'
                tp:1
                onClicking: {
                    raiz.showPlainText=!raiz.showPlainText
                }
                Text {
                    id: txtTT1
                    text: raiz.showPlainText?'<b>TXT<b>':'<b>HTML<b>'
                    anchors.centerIn: parent
                    font.pixelSize: parent.width*0.3
                    color: raiz.fontColor
                }
            }
            Boton{
                id:btnClear
                w:parent.height
                h: w
                t: '\uf12d'
                b: raiz.bgColor
                c: raiz.fontColor
                d:'Limpiar LogView'
                tp:1
                onClicking: {
                    logTxt.text=''
                }
            }
            Boton{
                id:btnHelp
                w:parent.height
                h: w
                t: '<b>?</b>'
                b: raiz.bgColor
                c: raiz.fontColor
                d:'Acerca de Unikast'
                tp:1
                onClicking: {
                   showInfo()
                }
            }
            Item{
                width: parent.height
                height: width
            }
            Boton{//a unik-tools
                w:parent.height
                h: w
                t: '\uf015'
                b: raiz.bgColor
                c: raiz.fontColor
                d:'Iniciar Unik-Tools'
                tp:1
                visible: !raiz.enUnikTools
                onClicking: {
                    unik.ejecutarLineaDeComandoAparte(appExec+' -folder='+appsDir+'/unik-tools  -cfg')
                }
            }
            Boton{
                id:btnFS
                w:parent.height
                h: w
                t: '\uf0b2'
                b: raiz.bgColor
                c: raiz.fontColor
                d:'FullScreen'
                tp:1
                onClicking: {
                    if(app.visibility===Window.FullScreen){
                        app.visibility='Windowed'
                    }else{
                        app.visibility='FullScreen'
                    }
                }
            }
            Boton{//Restart
                w:parent.height
                h: w
                t: '\uf021'
                b: raiz.bgColor
                c: raiz.fontColor
                d:'Reiniciar'
                tp:1
                visible: !raiz.enUnikTools
                onClicking: {
                    unik.restartApp()
                }
                Text {
                    text: "\uf011"
                    font.family: "FontAwesome"
                    font.pixelSize: parent.height*0.3
                    anchors.centerIn: parent
                    color: raiz.fontColor
                }
            }
            Boton{//Quit
                w:parent.height
                h: w
                t: "\uf011"
                b: raiz.bgColor
                c: raiz.fontColor
                d:'Apagar'
                tp:1
                visible: !raiz.enUnikTools
                onClicking: {
                    Qt.quit()
                }
            }
        }
    }

    onHeightChanged: appSettings.lvh=height
    Component.onCompleted: {
        if(raiz.showUnikInitMessages){
            var s=(''+unik.initStdString).replace(/\n/g, '<br />')
            var stdinit='<b>Start Unik Init Message:</b>\u21b4<br />'+s+'<br /><b>End Unik Init Message.</b><br />\n'
            var txt =''

            txt += "<b>OS: </b>"+Qt.platform.os

            var s2=(''+unikError).replace(/\n/g, '<br />')
            txt+=s2
            txt += '<b>unik version: </b>'+version+'<br />\n'
            txt += '<b>AppName: </b>'+appName+'<br />\n'
            var e;
            if(unikError!==''){
                txt += '\n<b>Unik Errors:</b>\n'+unikError+'<br />\n'
            }else{
                txt += '\n<b>Unik Errors:</b>none<br />\n'
            }
            txt += 'Doc location: '+appsDir+'/<br />\n'
            txt += 'host: '+host+'<br />\n'
            txt += 'user: '+ukuser+'<br />\n'
            if(ukuser==='unik-free'){
                txt += 'key: '+ukkey+'<br />\n'
            }else{
                txt += 'key: '
                var k= (''+ukkey).split('')
                for(var i=0;i<k.length;i++){
                    txt += '*'
                }
                txt += '<br />\n'
            }
            txt += 'sourcePath: '+sourcePath+'<br />\n'
            txt += '\n<b>config.json:</b>\n'+unik.getFile(appsDir+'/config.json')+'<br />\n'
            bodyText+=txt+'<br />'+stdinit
            logTxt.text+=bodyText
        }
        //unik.setProperty("setInitString", true)
        if(raiz.fontSize<=0){
            raiz.fontSize = 14
        }
    }
    function log(l){
        if((''+l).indexOf('QSslSocket')>-1){
            return
        }
        if(logTxt.text.length>raiz.maxLength){
            logTxt.text=''
        }
        logTxt.text+=l+'\n'
        if(fk.contentHeight>=raiz.height&&!fk.draged){
            fk.contentY=fk.contentHeight-fk.height
        }
    }
    function clear(){
        logTxt.text=''
    }
    function showInfo(){
        var data=''+unik.getFile(appsDir+'/'+app.moduleName+'/README.md')
        var m0=data.split('\n')
        var nd=''
        for(var i=0;i<m0.length;i++){
            var l=''+m0[i]
            if(l.substring(0,1)==='#'){
                nd+='<h1>'+l.substring(1,l.length)+'</h1>'
            }else if(l.substring(0,2)==='##'){
                    nd+='<h2>'+l.substring(3,l.length)+'</h2>'
            }else{
                nd+=l+'<br />'
            }
        }
        log(nd)
        if(raiz.height<400){
            raiz.height=400
        }
    }
}
