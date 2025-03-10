/**
MIT License

Copyright (c) 2017 Andrey Semenov

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import QtQuick 2.0
import QtQuick.Controls 1.4 as OldControls
import QtQuick.Controls 2.1
import Qt.labs.folderlistmodel 2.1
import QtQuick.Window 2.0
import "utils.js" as Utils

Item {
	id:picker
	signal fileSelected(string fileName)
	readonly property real textmargin: Utils.dp(Screen.pixelDensity, 8)
	readonly property real textSize: Utils.dp(Screen.pixelDensity, 10)
	readonly property real headerTextSize: Utils.dp(Screen.pixelDensity, 12)
	readonly property real buttonHeight: Utils.dp(Screen.pixelDensity, 24)
	readonly property real rowHeight: Utils.dp(Screen.pixelDensity, 36)
	readonly property real toolbarHeight: Utils.dp(Screen.pixelDensity, 48)
	property bool showDotAndDotDot: false
	property bool showHidden: true
	property bool showDirsFirst: true
	property string folder: "file:///sdcard"
	property string nameFilters: "*.*"

	function currentFolder() {
		return folderListModel.folder;
	}

	function isFolder(fileName) {
		return folderListModel.isFolder(folderListModel.indexOf(folderListModel.folder + "/" + fileName));
	}
	function canMoveUp() {
		return folderListModel.folder.toString() !== "file:///";
	}

	function onItemClick(fileName) {
		if(!isFolder(fileName)) {
            fileSelected(currentFolder() + '/' + fileName)
			return;
		}
		if(fileName === ".." && canMoveUp()) {
			folderListModel.folder = folderListModel.parentFolder
		} else if(fileName !== ".") {
			if(folderListModel.folder.toString() === "file:///") {
				folderListModel.folder += fileName
			} else {
				folderListModel.folder += "/" + fileName
			}
		}
	}
	Rectangle {
		id: toolbar
		anchors.right: parent.right
		anchors.left: parent.left
		anchors.top: parent.top
		height: toolbarHeight
		color: Utils.backgroundColor()
		Button {
			id: button
			text: ".."
			anchors.right: parent.right
			anchors.rightMargin: buttonHeight
			anchors.bottom: parent.bottom
			anchors.top: parent.top
			enabled: canMoveUp()
			flat: true
			onClicked: {
				if(canMoveUp) {
					folderListModel.folder = folderListModel.parentFolder
				}
			}
		}
		Text {
			id: filePath
			text: folderListModel.folder.toString().replace("file:///", "►").replace(new RegExp("/",'g'), "►")
			renderType: Text.NativeRendering
			elide: Text.ElideMiddle
			anchors.right: button.left
			font.italic: true
			font.bold: true
			verticalAlignment: Text.AlignVCenter
			anchors.left: parent.left
			anchors.leftMargin: buttonHeight
			anchors.bottom: parent.bottom
			anchors.top: parent.top
			font.pixelSize: textSize

		}
	}

	FolderListModel {
		id:  folderListModel
		showDotAndDotDot: picker.showDotAndDotDot
		showHidden: picker.showHidden
		showDirsFirst: picker.showDirsFirst
		folder: picker.folder
		nameFilters: picker.nameFilters
	}
	OldControls.TableView {
		id: view
		anchors.top: toolbar.bottom
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		model: folderListModel
		headerDelegate:headerDelegate
		rowDelegate: Rectangle {
			height: rowHeight
		}

		OldControls.TableViewColumn {
			title: qsTr("FileName")
			role: "fileName"
			resizable: true
			delegate: fileDelegate
		}

		Component {
			id: fileDelegate
			Item {
				height: rowHeight
				Rectangle {
					anchors.fill: parent
					MouseArea {
						anchors.fill: parent
						onClicked: {
							onItemClick(fileNameText.text)
						}
					}
					Text {
						id: fileNameText
						height: width
						anchors.left: image.right
						anchors.top: parent.top
						anchors.bottom: parent.bottom
						anchors.right: parent.right
						text: styleData.value !== undefined ? styleData.value : ""
						verticalAlignment: Text.AlignVCenter
					}
					Image {
						id: image
						height: buttonHeight
						width: height
						anchors.left: parent.left
						anchors.leftMargin: textmargin
						anchors.verticalCenter: parent.verticalCenter
                        source: isFolder(fileNameText.text) ? "qrc:/res/icons/ic_folder_open_black_48dp.png" : "qrc:/res/icons/ic_insert_drive_file_black_48dp.png"
					}
				}
			}
		}
		Component {
			id: headerDelegate
			Rectangle {
				height: rowHeight
				color: Utils.textAltColor()
				border.color: Utils.textAltColor()
				Text {
					anchors.verticalCenter: parent.verticalCenter
					anchors.horizontalCenter: parent.horizontalCenter
					height: headerTextSize
					font.bold: true
					elide: Text.ElideMiddle
					color: Utils.primaryColor()
					text: styleData.value !== undefined ? styleData.value : ""
				}
			}
		}
	}
}
