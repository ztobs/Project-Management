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

//import javafx.ext.swing.SwingList;
//import javafx.ext.swing.SwingListItem;
import javafx.scene.control.*;
import javafx.scene.Group;
import javafx.scene.input.KeyCode;
import javafx.scene.input.KeyEvent;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.*;
import javafx.scene.paint.Color;
import javafx.scene.text.Font;
import projectmanager.AppView;
import projectmanager.ProjectModel;
import projectmanager.TaskModel;

/**
 * Lists all the projects. Allows the user to add new tasks to
 * the existing project, add new projects and delete projects that
 * does not have any tasks associated with it.
 *
 * Same screen is opened in 2 modes - 1. Pick Project mode and 2. List project mode.
 * Pick project mode will only allow the user to pick the project where as list
 * project mode will allow the user to add/delete project and tasks.
 */

public class ProjectListView extends AppView {
    public var chooseProject: Boolean = false;
    
    public var selectedListIndex: Number = 1;
    public var projNames: String[] = dataHandler.getProjectCategoriesNames();

    public var task: TaskModel;

    /**
     * Trigger that keeps track of the progress value of the progress bar
     * shown within the popup. If progress is 100%, the screen changes.
     */
     var progress: Number = bind progressVal on replace {
        if (progress >= 100 and (not chooseProject)) {
            controller.showTasksList(list.selectedItem as String);
        }
    }

    /**
     * Updates the view to synchronize it with underlying data model
     */
    public var updateView:Boolean = bind dataHandler.updateProjectView on replace {
        if (updateView) {
            populateList();
            dataHandler.updateProjectView = false;
        }
    }
    

    /**
     * Deletes the selected project category if no task is assigned to this
     * category.
     */
    protected override function deleteData() {
        var success: Boolean = dataHandler.deleteProjectCategory((list.selectedItem).toString());
        if (success) {
            populateList();
        } else {
            showMessage("Delete Unsuccessful. Some tasks may already exist "
            "for this project.");
        }
    }

    /**
     * Function that populates the list. Typically called after some changes
     * to the underlying data model.
     */
    public function populateList() {
        projNames = dataHandler.getProjectCategoriesNames();
    }
    var buttonWidth = bind (screenWidth - 10) / 4.0;
    
    var addTaskButton: Button = Button {
        text: "Add Task"
        layoutInfo: LayoutInfo {
            width: bind buttonWidth
        }

        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                addProjButton.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
                list.requestFocus();
            } else if (ke.code == KeyCode.VK_ENTER or
                ke.code == KeyCode.VK_SPACE) {
                addTaskButton.fire();
            }
        }

        action: function() {
            if (chooseProject) {
                task.category = (list.selectedItem).toString();
                controller.showTaskDetails(task);
            } else {
                var projTask: TaskModel = TaskModel {
                    name: ""
                    priority: 3
                    percentCompletion: 0
                    reviewed: false
                    notes: ""
                    category: if (list.selectedItem != null and
                    list.selectedItem != "") then (list.selectedItem).toString()
                    else dataHandler.defProjCatName
                }
                controller.showTaskDetails(projTask);
            }

        }
        visible: bind if(chooseProject or projNames.size() == 0 ) then false
                        else true;
    }

    var addProjButton: Button = Button {
        text: "Add"
        layoutInfo: LayoutInfo {
            width: bind buttonWidth
        }
        visible: bind if (chooseProject) false else true
        action: function(){
            controller.showProjectCategoryDetails(null);
         }
         onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                if (not openButton.disable) {
                    openButton.requestFocus();
                } else {
                    doneButton.requestFocus();
                }
            } else if (ke.code == KeyCode.VK_UP) {
                addTaskButton.requestFocus();
            } else if (ke.code == KeyCode.VK_ENTER or
                ke.code == KeyCode.VK_SPACE) {
                addProjButton.fire();
            }

        }
    }

    var openButton: Button = Button {
        text: bind if (chooseProject or projNames.size() == 0 ) then "Cancel"
            else "Open"
        layoutInfo: LayoutInfo {
            width: bind buttonWidth
        }
        action: function () {
            if (openButton.text == "Open") {
                if (list.selectedItem != "" and list.selectedItem != null) {
                    var pc:ProjectModel =
                        dataHandler.getProjectCategory((list.selectedItem).toString());
                    showProgress(pc.name);
                }
            } else {
               controller.showTaskDetails(task);
            }
        }
        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                doneButton.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
                if (addProjButton.visible) {
                    addProjButton.requestFocus();
                } else if (addTaskButton.visible) {
                    addTaskButton.requestFocus();
                } else {
                    list.requestFocus();
                }
            } else if (ke.code == KeyCode.VK_ENTER or
                ke.code == KeyCode.VK_SPACE) {
                openButton.fire();
            }
        }
    }

    var doneButton: Button = Button {
        text: bind if(chooseProject) then "Select" else "Done"
        layoutInfo: LayoutInfo {
            width: bind buttonWidth
        }
        action: function(){
            if(chooseProject and list.selectedItem != "") {
                task.category = (list.selectedItem).toString();
                controller.showTaskDetails(task);
            } else if (chooseProject and list.selectedItem == "") {
                showMessage("Choose a project category.");
                return;
            } else {
                controller.showDefaultScreen();
            }
        }
        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                list.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
                openButton.requestFocus();
            } else if (ke.code == KeyCode.VK_ENTER or
                ke.code == KeyCode.VK_SPACE) {
                doneButton.fire();
            }
        }
    }

    var headingText: Label = Label {
        translateX: bind (screenWidth - headingText.boundsInLocal.width) / 2.0
        translateY: 10
        text: "Projects"
        textFill: Color.WHITE
        font: Font {
            name: "Bitstream Vera Sans Bold"
            size: 14
        }
    }

    
    var list: ListView = ListView {
        items: bind for(str in projNames) { str }
        onMouseClicked: function (me: MouseEvent) {
            if (me.clickCount >= 2 and chooseProject ) {
                task.category = (list.selectedItem).toString();
                controller.showTaskDetails(task);
            } else if (me.clickCount >= 2 and list.selectedItem != "" and list.selectedItem != null) {
                var pc:ProjectModel =
                    dataHandler.getProjectCategory((list.selectedItem).toString());
                showProgress("Tasks for {pc.name}");
            }
        }

        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_ENTER and chooseProject) {
                task.category = (list.selectedItem).toString();
                controller.showTaskDetails(task);
            } else if (ke.code == KeyCode.VK_ENTER and list.selectedItem != ""
                and list.selectedItem != null) {
                var pc:ProjectModel =
                    dataHandler.getProjectCategory((list.selectedItem).toString());
                showProgress(pc.name);
            } else if (ke.code == KeyCode.VK_TAB or ke.code == KeyCode.VK_RIGHT) {
                if (addTaskButton.visible) {
                    addTaskButton.requestFocus();
                } else if (addProjButton.visible) {
                    addProjButton.requestFocus();
                } else {
                    openButton.requestFocus();
                }

            } else if (ke.code == KeyCode.VK_LEFT) {
                doneButton.requestFocus();
            }
        }

        translateX: 0
        translateY: bind (headingText.translateY + headingText.boundsInLocal.height + 10)
        width: screenWidth
        height: bind (screenHeight - headingText.boundsInLocal.height - buttonHbox.boundsInLocal.height - 35)
    }


    var buttonHbox: HBox = HBox {
        translateY: bind screenHeight - (buttonHbox.boundsInLocal.height) -  7;
        translateX: 4
        content: [addTaskButton, addProjButton, openButton, doneButton]
        spacing: 1
    }

    protected override function createView(): Void {
        defControl = list;
        view = Group {
            content: [headingText, list, buttonHbox]
        }
    }
}
