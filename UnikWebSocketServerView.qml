import QtQuick 2.0
import QtQuick.Controls 2.0
import Qt.WebSockets 1.0

Item {
    id: r
    anchors.fill: parent
    property string ip: '127.0.0.1'
    property int port: 12345
    property string serverName: 'chatserver'
    property bool inverted: false
    property var whitelist: []
    Component.onCompleted:{
        var appArgs = Qt.application.arguments
        for(var i=0;i<appArgs.length;i++){
            console.log('------------------->'+appArgs[i])
            var arg=''+appArgs[i]
            if(arg.indexOf('-ip=')===0){
                var m0=arg.split('=')
                r.ip=m0[1]
            }
        }
        unik.startWSS(r.ip, r.port, r.serverName);
        //unik.initWebSocketServer(r.ip, r.port, r.serverName);
        //listModelUser.updateUserList()
    }
    Connections {
        id:connCW
        //target: cw
        onClientConnected:{
            console.log("A new client connected.")
        }
    }
    Timer{
        running:true
        repeat:true
        interval: 1000
        onTriggered: {
            if(cw){
                connCW.target=cw
            }

        }
    }
    Connections {
        target: cs
        onUserListChanged:{
            listModelUser.updateUserList()
        }
        onNewMessage:{
            var time=new Date(Date.now()).getTime()
            let json=JSON.parse(msg)
            json.serverData={}
            json.serverData.time=time
            console.log('NewMessage: '+JSON.stringify(json))
            console.log('NewMessage from: ['+json.from+']')
            console.log('NewMessage to: ['+json.to+']')
            console.log('NewMessage data: ['+json.data+']')
            if(json.to==='minyma'&&r.whitelist.indexOf(json.from)>=0){
                let cmd=json.data
                cmd=cmd.replace('\\\\"', '"')
                let bf='#!/bin/bash\n'
                bf+=''+cmd+'\n'
                bf+='exit 0;'
                let d=new Date(Date.now())
                let ms=d.getTime()
                let fn='script_'+ms+'.sh'
                let ffn=unik.getPath(3)+'/'+fn
                unik.setFile(ffn, bf)
                unik.run('chmod a+x '+ffn)
                unik.ejecutarLineaDeComandoAparte(ffn)

            }else{
                listModelMsg.addMsg(json)
            }

        }
    }
    Column{
        anchors.fill: parent
        Row{
            width: parent.width
            height: parent.height-28
            Rectangle{
                width: parent.width*0.7
                height: parent.height
                border.width: 1
                clip: true
                Rectangle{
                    width: parent.width
                    height: 28
                    color: "black"
                    Text {
                        text: "<b>Messages</b>"
                        font.pixelSize: 24
                        anchors.centerIn: parent
                        color: "white"
                    }
                }
                ListView{
                    id:msgListView;
                    width: parent.width;
                    height: parent.height-28;
                    y:28; spacing: 10;
                    clip: true;
                    model: listModelMsg;
                    delegate: delegateMsg;
                    //verticalLayoutDirection: msgListView.BottomToTop
                }
            }
            Rectangle{
                width: parent.width*0.3
                height: parent.height
                border.width: 1
                clip: true
                Rectangle{
                    width: parent.width
                    height: 28
                    color: "black"
                    Text {
                        text: "<b>User List</b>"
                        font.pixelSize: 24
                        anchors.centerIn: parent
                        color: "white"
                    }
                }
                ListView{id:userListView;width: parent.width; height: parent.height-28; y:28; spacing: 10; clip: true; model: listModelUser; delegate: delegateUser;}
            }
        }
    }
    ListModel{
        id: listModelUser
        function createElement(u){
            return {
                user: u
            }
        }
        function updateUserList(){
            clear()
            var ul = cs.userList;
            for(var i=0; i < ul.length; i++){
                append(createElement(ul[i]))
            }
        }
    }
    ListModel{
        id: listModelMsg
        function createElement(j){
            return {
                json: j
            }
        }
        function addMsg(msg){
            if(r.inverted){
                insert(0, createElement(msg))
                msgListView.currentIndex = 0
            }else{
                append(createElement(msg))
                msgListView.currentIndex = count-1
            }
        }
    }
    Component{
        id: delegateUser
        Rectangle{
            width: userListView.width*0.9
            height: 24
            border.width: 1
            color: "#cccccc"
            radius: 6
            //anchors.horizontalCenter: parent.horizontalCenter
            clip:true
            Text {
                text: "<b>"+user+"</b>"
                font.pixelSize: 20
                anchors.centerIn: parent
            }
        }
    }
    Component{
        id: delegateMsg
        Rectangle{
            width: msgListView.width*0.98
            height: col.height+app.fs
            border.width: 1
            color: "#cccccc"
            radius: 6
            anchors.horizontalCenter: parent.horizontalCenter
            clip:true
            Column{
                id: col
                spacing: app.fs*0.5
                anchors.centerIn: parent
                Row{
                    spacing: app.fs*0.5
                    Text {
                        id: txtFrom
                        font.pixelSize: app.fs*0.5
                        anchors.verticalCenter: parent.verticalCenter
                        wrapMode: Text.WordWrap
                    }
                    Text {
                        id: txtTo
                        font.pixelSize: app.fs*0.5
                        anchors.verticalCenter: parent.verticalCenter
                        wrapMode: Text.WordWrap
                    }
                }
                Text {
                    id: txtData
                    width: msgListView.width-app.fs*0.5
                    font.pixelSize: app.fs*0.5
                    anchors.horizontalCenter: parent.horizontalCenter
                    wrapMode: Text.WordWrap
                }
            }
            Component.onCompleted: {
                txtFrom.text='<b>From:</b> ' + json.from
                txtTo.text='<b>To:</b> ' + json.to
                txtData.text='<b>Data:</b>\n' + json.data
            }
        }
    }
}
