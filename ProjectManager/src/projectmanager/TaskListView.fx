/* 
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER
 * Copyright 2009 Sun Microsystems, Inc. All rights reserved. Use is subject to license terms. 
 * 
 * This file is available and licensed under the following license:
 * 
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted provided that the following conditions are met:
 *
 *   * Redistributions of source code must retain the above copyright notice, 
 *     this list of conditions and the following disclaimer.
 *
 *   * Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *
 *   * Neither the name of Sun Microsystems nor the names of its contributors 
 *     may be used to endorse or promote products derived from this software 
 *     without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package projectmanager;

import javafx.geometry.HPos;
import javafx.geometry.VPos;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.ListView;
import javafx.scene.control.ToggleButton;
import javafx.scene.control.ToggleGroup;
import javafx.scene.input.KeyCode;
import javafx.scene.input.KeyEvent;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.HBox;
import javafx.scene.layout.LayoutInfo;
import javafx.scene.layout.VBox;
import javafx.scene.paint.Color;
import javafx.scene.shape.Rectangle;
import javafx.scene.text.Font;
import projectmanager.AppView;
import javafx.scene.Node;
import javafx.scene.text.Text;
import javafx.scene.text.TextOrigin;

import javafx.scene.Group;

/**
 * Shows the list of tasks categorized as High, Medium and Low.
 * Provides options to add new tasks, to view projects and to delete any existing
 * tasks.
 */
public class TaskListView extends AppView {

    public var taskNames: String[];
    public var buttonGroup: ToggleGroup = new ToggleGroup;
    public var projCat: String = "";
    var openProjEditor: Boolean = false;

    var progress: Number = bind progressVal on replace {
        if (progress >= 100) {
            if (not openProjEditor) {
                var projTask = dataHandler.getProjectTask((list.selectedItem).toString());
                controller.showTaskDetails(projTask);
            } else {
                controller.showProjectCategoryDetails(dataHandler.getProjectCategory(projCat));
            }
            openProjEditor = false;
        }
    }

    public var updateView: Boolean = bind dataHandler.updateTaskView on replace {
        if (updateView) {
            populateList(selectedButtonAction);
            dataHandler.updateTaskView = false;
        }
    }


    protected override function deleteData() {
        dataHandler.deleteProjectTask((list.selectedItem).toString());
        if (projCat == "") {
            populateList(buttonGroup.selectedButton);
        } else {
            populateList(buttonGroup.selectedButton, projCat);
        }
    }


    var selectedButtonAction: ToggleButton = bind buttonGroup.selectedButton on replace {
        if (selectedButtonAction != null) {
            if (projCat == "") {
                populateList(selectedButtonAction);
            } else {
                populateList(selectedButtonAction, projCat);
            }
        }
    }

    public function populateList(selectedButtonAction: ToggleButton) {
        if(selectedButtonAction.text == "All" ) {
            taskNames = dataHandler.getProjectTasksNames();
        } else
        if(selectedButtonAction.text == "High" ) {
            taskNames = dataHandler.getProjectTasksNames(1);
        } else
        if(selectedButtonAction.text == "Medium" ) {
            taskNames = dataHandler.getProjectTasksNames(2);
        } else
        if(selectedButtonAction.text == "Low" ) {
            taskNames = dataHandler.getProjectTasksNames(3);
        }
    }

    public function populateList(selectedButtonAction: ToggleButton, projCategory: String) {
        if(selectedButtonAction.text == "All" ) {
            taskNames = dataHandler.getProjectTasksNames(projCategory);
        } else
        if(selectedButtonAction.text == "High" ) {
            taskNames = dataHandler.getProjectTasksNames(1, projCategory);
        } else
        if(selectedButtonAction.text == "Medium" ) {
            taskNames = dataHandler.getProjectTasksNames(2, projCategory);
        } else
        if(selectedButtonAction.text == "Low" ) {
            taskNames = dataHandler.getProjectTasksNames(3, projCategory);
        }
    }

    var buttonWidth = (screenWidth - 10) / 4.0;
    var highButton: ToggleButton = ToggleButton {
        text: "High"
        toggleGroup: buttonGroup
        layoutInfo: LayoutInfo {
            width: buttonWidth
        }
        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                medButton.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
                if (projCat == "" and taskNames.size() != 0) {
                    openButton.requestFocus();
                } else if (taskNames.size() == 0) {
                    projectButton.requestFocus();
                } else if (projCat != "") {
                    text.requestFocus();
                }
            } else if (ke.code == KeyCode.VK_ENTER) {
                highButton.fire();
            }
        }
    }

    var medButton: ToggleButton = ToggleButton {
        text: "Medium"
        toggleGroup: buttonGroup
        layoutInfo: LayoutInfo {
            width: buttonWidth
        }
        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                lowButton.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
                highButton.requestFocus();
            } else if (ke.code == KeyCode.VK_ENTER) {
            // or ke.code == KeyCode.VK_SPACE) {
                medButton.fire();
            }
        }
    }

    var lowButton: ToggleButton = ToggleButton {
        text: "Low"
        toggleGroup: buttonGroup
        layoutInfo: LayoutInfo {
            width: buttonWidth
        }
        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                allButton.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
                medButton.requestFocus();
            } else if (ke.code == KeyCode.VK_ENTER) {
               //or ke.code == KeyCode.VK_SPACE) {
                lowButton.fire();
            }
        }
    }

    public var allButton: ToggleButton = ToggleButton {
        text: "All"
        selected: true
        toggleGroup: buttonGroup
        layoutInfo: LayoutInfo {
            width: buttonWidth
        }
        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                list.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
                lowButton.requestFocus();
            } else if (ke.code == KeyCode.VK_ENTER) {
                //or ke.code == KeyCode.VK_SPACE) {
                allButton.fire();
            }
        }
    }

    var addButton: Button = Button {
        text: "Add"
        action: function() {
            if (projCat == "") {
                controller.showTaskDetails(null);
            } else {
                var projTask: TaskModel = TaskModel {
                    name: ""
                    category: projCat
                    priority: 1
                    key: -1
                }
                controller.showTaskDetails(projTask);
            }
        }

        layoutInfo: LayoutInfo {
            width: buttonWidth - 4
        }
        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                projectButton.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
                list.requestFocus();
            } else if (ke.code == KeyCode.VK_ENTER) {
                // or ke.code == KeyCode.VK_SPACE) {
                addButton.fire();
            }
        }
    }

    var projectButton: Button = Button {
        text: "Projects"
        action: function() {
            controller.showProjectDetails();
        }
        layoutInfo: LayoutInfo {
            width: buttonWidth - 4
        }
        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                if (taskNames.size() != 0) {
                    deleteButton.requestFocus();
                } else {
                    if (projCat == "") {
                        highButton.requestFocus();
                    } else {
                        text.requestFocus();
                    }
                }
            } else if (ke.code == KeyCode.VK_UP) {
                addButton.requestFocus();
            } else if (ke.code == KeyCode.VK_ENTER) {
            // or ke.code == KeyCode.VK_SPACE) {
                projectButton.fire();
            }
        }
    }

    var deleteButton: Button = Button {
        text: "Delete"
        layoutInfo: LayoutInfo {
            width: buttonWidth - 4
        }
        disable: bind
        if( taskNames.size() == 0 ) then true else false;
        action: function() {
            if (list.selectedItem != null and list.selectedItem != "") {
                deleteConfirmation(taskNames[list.selectedIndex]);
            }
        }
        
        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                openButton.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
               projectButton.requestFocus();
            } else if (ke.code == KeyCode.VK_ENTER) {
                //or  ke.code == KeyCode.VK_SPACE) {
                deleteButton.fire();
            }
        }
    }

    var openButton: Button = Button {
        text: "Open"
        action: function() {
            if (list.selectedItem != "" and list.selectedItem != null) {
                var projTask = dataHandler.getProjectTask((list.selectedItem).toString());
                showProgress(projTask.name);
            }
        }
        disable: bind
            if( taskNames.size() == 0 ) then true else false;
        layoutInfo: LayoutInfo {
            width: buttonWidth - 4
        }
        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                if (projCat == "") {
                    highButton.requestFocus();
                } else {
                    text.requestFocus();
                }
            } else if (ke.code == KeyCode.VK_UP) {
                if (taskNames.size() != 0) {
                    deleteButton.requestFocus();
                } else {
                    projectButton.requestFocus();
                }
            } else if (ke.code == KeyCode.VK_ENTER) {
                openButton.fire();
            }
        }
    }


    var headingLabel: Label = Label {
        text: "Tasks"
        textFill: Color.WHITE
        layoutInfo: LayoutInfo {
            hpos: HPos.CENTER,
            vpos: VPos.CENTER
            height: 30
        }
        font: Font {
            name: "Bitstream Vera Sans Bold"
            size: 14
        }
    };

    var text: Text = Text {
    	content: bind projCat
    	textOrigin: TextOrigin.TOP
        fill: Color.WHITE
        layoutInfo: LayoutInfo {
            hpos: HPos.CENTER
            vpos: VPos.CENTER
        }
        clip: Rectangle {
            x: 0
            y: 0
            width: bind (5.0/7.0 * screenWidth)
            height: 30
            fill:Color.TRANSPARENT
        }
        focusTraversable: true
    	font: Font {
            name: "Bitstream Vera Sans Bold"
            size: 14
        }

        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                highButton.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
               if (taskNames.size() == 0) {
                   projectButton.requestFocus();
               } else {
                   openButton.requestFocus();
               }
            } else if (ke.code == KeyCode.VK_ENTER or
            ke.code == KeyCode.VK_SPACE) {
                openProjEditor = true;
                showProgress(projCat);
            }
        }
    };

    var headingText: Node = bind if (projCat == "") then headingLabel else text;
    
    var rect: Rectangle = Rectangle {
        x: bind headingText.boundsInParent.minX
        y: bind headingText.boundsInParent.minY
        width: bind headingText.boundsInParent.width
        height: bind headingText.boundsInParent.height
        fill: Color.TRANSPARENT
        stroke: bind if (text.focused) then Color.web("#0093ff") else Color.TRANSPARENT
        strokeWidth: 2
        onMouseEntered: function(me: MouseEvent) {
    		if (headingText instanceof Text) {
                (headingText as Text).underline = true;
            }
    	}

    	onMouseExited: function(me: MouseEvent) {
            if (headingText instanceof Text) {
                (headingText as Text).underline = false;
            }
    	}

        onMouseClicked: function(me: MouseEvent) {
            if (headingText instanceof Text) {
                openProjEditor = true;
                showProgress(projCat);
            }
        }
    }

    var headingBox = HBox {
    	content: Group {
            content: bind [rect, headingText]
        }
  		
   		nodeVPos: VPos.CENTER
        vpos: VPos.CENTER
   		layoutInfo: LayoutInfo {
            hpos: HPos.CENTER
            height: 30
        }
    }
    
    var bottomButtonBox: HBox = HBox {
        translateX: 8
        content: [addButton, projectButton, deleteButton, openButton]
        spacing: 4
    }
    
    var list: ListView = ListView {
        translateX: 0
        layoutInfo: LayoutInfo {
            width: screenWidth
            height: bind (screenHeight - 30 -
                highButton.height - deleteButton.height - 15)
        }
        items: bind
            for(str in taskNames) {
                str;
            }
        onMouseClicked: function (me: MouseEvent) {
            if (me.clickCount >= 2) {
                var projTask = dataHandler.getProjectTask((list.selectedItem).toString());
                showProgress(projTask.name);
            }
        }

        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_ENTER and list.selectedItem != "" and list.selectedItem != null) {
                var projTask = dataHandler.getProjectTask((list.selectedItem).toString());
                showProgress(projTask.name);
            } else if (ke.code == KeyCode.VK_RIGHT) {
                addButton.requestFocus();
            } else if (ke.code == KeyCode.VK_LEFT) {
                allButton.requestFocus();
            }
        }
    }

    var topButtonBox: HBox = HBox {
        translateX: 5
        content: [highButton, medButton, lowButton, allButton ]
        spacing: 0
    }

    
    
    protected override function createView(): Void {
        defControl = allButton;
        view = VBox {
            content: [
                headingBox,
                topButtonBox,
                list,
                Rectangle { x: 0 y: 0 width: screenWidth height: 7, fill: Color.TRANSPARENT },
                bottomButtonBox ]
        };
    }
}
