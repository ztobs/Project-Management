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
/*
 * ProjectEditorView.fx
 *
 * Created on Apr 28, 2009, 8:42:43 PM
 */

package projectmanager;

import javafx.scene.control.*;
import javafx.scene.Group;
import javafx.scene.layout.*;
import javafx.scene.paint.Color;
import javafx.scene.text.Font;

import javafx.scene.input.KeyCode;
import javafx.scene.input.KeyEvent;

/**
 * Allows the user to edit project details such as name and description.
 * User can also delete the project that does not have any tasks.
 */
public class ProjectEditorView extends AppView {
    
    public var projCat: ProjectModel on replace {
        if (projCat != null) {
            initializeProject(true);
        } else {
            initializeProject(false)
        }
    };

    /**
     * Initializes the project editor screen depending on the mode -
     * Edit Project or New Project.
     */
    public function initializeProject(isCatNotNull: Boolean) {
        if (isCatNotNull) {
            nameTextBox.text = projCat.name;
            notesTextBox.text = projCat.description;
        } else {
            nameTextBox.text = "";
            notesTextBox.text = "";
        }
    }

    /**
     * Deletes the project category if no task is created with this
     * category. Default project category also can not be deleted.
     */
    protected override function deleteData() {
        if (projCat.name == dataHandler.defProjCatName) {
            showMessage("Default project category can not be deleted.");
            return;
        }

        if( projCat != null ) {
            var success = dataHandler.deleteProjectCategory(projCat);
            if (success) {
                controller.showProjectDetails();
            } else {
                showMessage("Delete Unsuccessful. Some tasks may already exist for this project.");
            }
        }
    }

    var buttonWidth = (screenWidth - 10) / 3.0;
    
    var nameLabel: Label = Label {
        text: "Name"
        textFill: Color.WHITE
    }

    var nameTextBox: TextBox = TextBox {
        columns: 25
        text: if(projCat != null) then projCat.name else ""
        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                notesTextBox.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
                doneButton.requestFocus();
            }
        }
    }    
    var notesTextBox: TextBox = TextBox {
        columns: 25
        text: if(projCat != null) then projCat.description else ""

        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                if (deleteButton.visible) {
                    deleteButton.requestFocus();
                } else {
                    cancelButton.requestFocus();
                }
            } else if (ke.code == KeyCode.VK_UP) {
                nameTextBox.requestFocus();
            }
        }
    }        
    var notesLabel: Label = Label {
        text: "Notes"
        textFill: Color.WHITE
    }
    var cancelButton: Button = Button {
        text: "Cancel"
        layoutInfo: LayoutInfo { width: bind buttonWidth }
        action: function() {
            //controller.showProjectDetails();
            if (projCat == null) {
                controller.showProjectDetails();
            } else {
                controller.showTasksList(projCat.name);
            }
        }

        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                doneButton.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
                if (deleteButton.visible) {
                    deleteButton.requestFocus();
                } else {
                    notesTextBox.requestFocus();
                }
            } else if (ke.code == KeyCode.VK_ENTER or
                ke.code == KeyCode.VK_SPACE) {
                cancelButton.fire();
            }
        }
    }

    

    var deleteButton: Button = Button {
        text: "Delete"
        layoutInfo: LayoutInfo { width: bind buttonWidth }
        visible: bind if (projCat == null) false else true
        action: function() {
            deleteConfirmation(projCat.name);
        }

        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                cancelButton.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
                notesTextBox.requestFocus();
            } else if (ke.code == KeyCode.VK_ENTER or
                ke.code == KeyCode.VK_SPACE) {
                deleteButton.fire();
            }
        }
    }

    var doneButton: Button = Button {
        text: "Done"
        layoutInfo: LayoutInfo { width: bind buttonWidth }

        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                nameTextBox.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
                cancelButton.requestFocus();
            } else if (ke.code == KeyCode.VK_ENTER or
                ke.code == KeyCode.VK_SPACE) {
                doneButton.fire();
            }
        }

        action: function() {
            if (nameTextBox.text == null or nameTextBox.text == "") {
                showMessage("Please enter a project name.");
                return;
            }
            if (projCat.name == dataHandler.defProjCatName) {
                showMessage("Default project category can not be modified.");
                return;
            }
            var pCat: ProjectModel = ProjectModel {
                    name: nameTextBox.rawText
                    description: notesTextBox.rawText
                }
            if( projCat != null ) {
                pCat.key = projCat.key;
                var success = dataHandler.updateProjectCategory(pCat);
                if (success == 1) {
                    showMessage("This project already exists.");
                } else if (success == 2) {
                    showMessage("Project names cannot be changed once they are assigned to a task.");
                } else {
                    controller.showTasksList(pCat.name);
                }
            } else {
                var success = dataHandler.addProjectCategory(pCat);
                if (not success) {
                    showMessage("This project already exists.");
                } else {
                    controller.showProjectDetails();
                }
            }
        }
    }

    var headingText: Label = Label {
        font: Font {
            name: "Bitstream Vera Sans Bold"
            size: 14
        }
        text: bind if(projCat != null) then projCat.name else
        "New Project"
        translateX: bind (screenWidth - headingText.boundsInLocal.width) / 2.0
        translateY: 10
        textFill: Color.WHITE
        width: bind (5.0/6.0 * screenWidth)
    }

    var nameVbox: VBox = VBox {
        content: [nameLabel, nameTextBox]
        spacing: 5
    }

    var noteVbox:VBox = VBox {
        content: [notesLabel, notesTextBox]
        spacing: 5
    }

    var nameNoteVBox: VBox = VBox {
        translateY: bind headingText.boundsInLocal.height + 20
        translateX: 10
        content: [nameVbox, noteVbox]
        spacing: bind screenHeight/21.3333
    }


    var buttonBox: HBox = HBox {
        translateX: 4
        translateY: bind (screenHeight - buttonBox.boundsInLocal.height - 7)
        content: [deleteButton, cancelButton, doneButton]
        spacing: 2
    }

   
    protected override function createView(): Void {
        defControl = nameTextBox;
        view = Group {
            content: [headingText, nameNoteVBox, buttonBox]
        }
    }
}
