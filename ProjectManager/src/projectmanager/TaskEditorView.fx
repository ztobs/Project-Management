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
import javafx.scene.control.*;
import javafx.scene.Group;
import javafx.scene.layout.*;
import javafx.scene.paint.Color;
import javafx.scene.text.Font;
import javafx.scene.text.Text;

import javafx.scene.input.KeyCode;
import javafx.scene.input.KeyEvent;

/**
 * Allows the user to modify the task details such as task name,
 * priority, percentage completion, task notes, etc.
 * Also allows to delete the task.
 */
public class TaskEditorView extends AppView {
    /*
     * Toggle Group for the priority radio buttons
     */
    public var buttonGroup: ToggleGroup = ToggleGroup {
    };
    
    /**
     * Height defined for the buttons as a proportion of screen size
     */
    var buttonsWidth = (screenWidth - 10) / 4.0;

    /**
     * Width defined for the buttons as a proportion of screen size
     */
    var buttonWidth = (screenWidth - 10) / 3.0 - 4;

    /**
     * Task represented by this editor view. The task that is
     * currently being edited.
     */
    public var task: TaskModel on replace {
        if (task != null) {
            initializeTask(true);
        } else {
            initializeTask(false)
        }
    }

    public var priorityVal: Number = 0;

    public var priorityText: String = bind buttonGroup.selectedButton.id on replace {
        if( priorityText == "High") {
            priorityVal = 1;
        } else if( priorityText == "Medium") {
            priorityVal = 2;
        } else if( priorityText == "Low") {
            priorityVal = 3;
        }
    }
    var nameVal: String = bind nameTextBox.rawText;
    var notesVal: String = bind notesTextBox.rawText;
    var catVal: String = bind task.category;
    var percentVal: Number = bind slider.value;
    var reviewVal: Boolean = bind reviewCheckBox.selected;

    /**
     * Initializes the task when the screen is opened in edit and
     * new task mode. The initialize parameter identifies if the screen
     * is meant to be opened in edit or new task mode and initializes the
     * fields accordingly.
     */
    protected function initializeTask(initialize: Boolean) {
        if (initialize) {
            nameTextBox.text = if (task.name != null) then task.name else task.notes;
            notesTextBox.text = task.notes;
            highRadioButton.selected = if (task.priority == 1 ) then true else false;
            medRadioButton.selected = if (task.priority == 2) then true else false;
            lowRadioButton.selected = if (task.priority == 3 ) then true else false;
            reviewCheckBox.selected = task.reviewed;
            slider.value = task.percentCompletion;
        } else {
            nameTextBox.text = "";
            notesTextBox.text = "";
            highRadioButton.selected = false;
            medRadioButton.selected = false;
            lowRadioButton.fire();
            reviewCheckBox.selected = false;
            slider.value = 0;
        }
    }

    /**
     * Invoked when the user presses the 'delete' button. Once the task
     * is deleted, the control goes back to the generic task list
     * page or project specific task list, depending on
     * where the control came from.
     */
    protected override function deleteData() {
        dataHandler.deleteProjectTask(task);
        if (controller.projectSpecific) {
            controller.showTasksList(task.category);
        } else {
            controller.showDefaultScreen();
        }
    }

    /**
     * Heading Label that displays the task name in edit mode. In 'New Task'
     * mode, it shows the heading applicable for the new task.
     */
    var headingText: Label = Label {
        translateX: bind (screenWidth - headingText.boundsInLocal.width) / 2.0
        translateY: 10
        width: bind (5.0/6.0 * screenWidth)

        text: bind if (task == null) then "New Task" else 
            if (task != null and task.key == -1) "New Task" else
            "Task: {dataHandler.getProjectTask(task.key).name}"
        textFill: Color.WHITE
        font: Font {
            name: "Bitstream Vera Sans Bold"
            size: 14
        }
    }

    /**
     * Label for the Name text field
     */
    var nameLabel: Label = Label {
        text: "Task Name"
        layoutInfo: LayoutInfo { width: bind screenWidth }
        textFill: Color.WHITE
    }

    /**
     * TextBox that accepts the task name.
     */
    var nameTextBox: TextBox = TextBox {
        columns: 25
        text: if (task != null and task.name != null ) then task.name else ""

        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                changeButton.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
                doneButton.requestFocus();
            }
        }
    }

    /**
     * Project Category to which this task belongs. By default, it will
     * be unknown if no category is assigned to the task. If this screen is
     * opened from 'Add Task' option in task list for a specific project cat,
     * the respective category will be assigned by default.
     */
    var projectLabel: Label = Label {
        text: bind if (task == null) then "Project: {dataHandler.defProjCatName}"
            else "Project: {task.category}"
        layoutInfo: LayoutInfo {
            width: bind screenWidth / 1.5
        }
        textFill: Color.WHITE
    }

    /**
     * Allows the user to change the project category.
     */
    var changeButton:Button = Button {
        id: bind if( task == null ) then "Assign" else "Change"
        text: bind if( task == null ) then "Assign" else "Change"
        action: function () {
            var projTask: TaskModel = TaskModel {
                name: nameTextBox.rawText
                category: catVal
                priority: priorityVal
                key: if (task != null) task.key else -1
                percentCompletion: slider.value
                reviewed: reviewCheckBox.selected
                notes: notesTextBox.rawText
            }
            controller.showProjectsList(projTask, true);
        }

        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                highRadioButton.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
                nameTextBox.requestFocus();
            } else if (ke.code == KeyCode.VK_ENTER or
                ke.code == KeyCode.VK_SPACE) {
                changeButton.fire();
            }

        }

        layoutInfo: LayoutInfo { width: bind buttonsWidth }
    }

    /**
     * Label for the notex text box.
     */
    var notesLabel: Label = Label {
        text: "Notes"
        textFill: Color.WHITE
        layoutInfo: LayoutInfo {
            width: bind screenWidth / 2
            hpos: HPos.LEFT
            vpos: VPos.CENTER
        }
    }

    var priorityLabel: Label = Label {
        text: "Priority"
        textFill: Color.WHITE
        layoutInfo: LayoutInfo {
            width: bind screenWidth / 2
        }
    }

    /**
     * Allows the user to add a note about the task.
     */
    var notesTextBox: TextBox = TextBox {
        columns: 25
        text: if (task == null) then "" else task.notes
        layoutInfo: LayoutInfo {
            hpos: HPos.LEFT
            vpos: VPos.CENTER
        }

        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                slider.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
                reviewCheckBox.requestFocus();
            }
        }
    }

    /**
     * Denotes this task is of high priority
     */
    var highRadioButton: RadioButton = RadioButton {
        id: "High"
        graphic: Text {
            content: "High"
            fill: Color.WHITE
        }
        graphicHPos: HPos.RIGHT

        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                medRadioButton.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
                changeButton.requestFocus();
            } else if (ke.code == KeyCode.VK_ENTER or
                ke.code == KeyCode.VK_SPACE) {
                highRadioButton.fire();
            }
        }
        
        toggleGroup: buttonGroup;
        selected: if (task != null and task.priority == 1 ) then true
                        else false
    }

    /**
     * Denotes this task is of medium priority
     */
    var medRadioButton: RadioButton = RadioButton {
        id: "Medium"
        graphic: Text {
            content: "Medium"
            fill: Color.WHITE
        }

        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                lowRadioButton.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
                highRadioButton.requestFocus();
            } else if (ke.code == KeyCode.VK_ENTER or
                ke.code == KeyCode.VK_SPACE) {
                medRadioButton.fire();
            }
        }
        
        graphicHPos: HPos.RIGHT
        toggleGroup: buttonGroup;
        selected: if (task != null and task.priority == 2 ) then true
                        else false
    }

    /**
     * Denotes this task is of low priority
     */
    var lowRadioButton: RadioButton = RadioButton {
        id: "Low"
        graphic: Text {
            content: "Low"
            fill: Color.WHITE
        }

        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                reviewCheckBox.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
                medRadioButton.requestFocus();
            } else if (ke.code == KeyCode.VK_ENTER or
                ke.code == KeyCode.VK_SPACE) {
                lowRadioButton.fire();
            }
        }
        
        graphicHPos: HPos.RIGHT
        toggleGroup: buttonGroup;
        selected: true
    }

    /**
     * HBox which holds all the radio buttons
     */
   var radioHBox: HBox = HBox {
        content: [ highRadioButton, medRadioButton, lowRadioButton ]
        spacing: 5
    }

    /**
     * Indicates whether this task has already been reviewed or not
     */
    var reviewCheckBox: CheckBox = CheckBox {
        graphic: Text {
            content: "Reviewed"
            fill: Color.WHITE
        }
        graphicHPos: HPos.RIGHT
        selected: if (task != null ) then task.reviewed else false
        layoutInfo: LayoutInfo {
            width: bind screenWidth
        }
        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                notesTextBox.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
                lowRadioButton.requestFocus();
            } else if (ke.code == KeyCode.VK_ENTER) {
                reviewCheckBox.fire();
            }
        }
    }

    /**
     * HBox that holds the project name and project change control.
     */
    var projHBox = HBox {
        content: [projectLabel, changeButton]
        spacing: 5
    }

    /**
     * VBox which holds the task name label and text box
     */
    var nameVBox = VBox {
        content: [ nameLabel, nameTextBox ]
        spacing: 3
    }

    /**
     * VBox that holds all the radio buttons and the priority label
     */
    var priorityVBox = VBox {
        content: [priorityLabel, radioHBox]
        spacing: 3
    }

    /**
     * VBox that holds the notes label and text box
     */
    var notesVBox = VBox {
        content: [notesLabel, notesTextBox]
        spacing: 3
    }

    /**
     * Label for the percentage slider
     */
    var percentLabel: Label = Label {
        text: "Percent Completion"
        textFill: Color.WHITE
    }

    /**
     * Slider which indicates the percentage completion of the task
     * that is added/edited
     */
    var slider: Slider = Slider {
        min: 1
        max: 3
        snapToTicks: true
        showTickLabels: true
        showTickMarks: true
        majorTickUnit: 1
        minorTickCount: 0
        value: if (task != null ) then task.percentCompletion
                        else 0
        width: bind screenWidth - 20

        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                if (deleteButton.visible) {
                    deleteButton.requestFocus();
                } else {
                    cancelButton.requestFocus();
                }
            } else if (ke.code == KeyCode.VK_UP) {
                notesTextBox.requestFocus();
            }
        }
    }

    var sliderVbox: VBox = VBox {
        content: [percentLabel, slider]
        spacing: 3
    }


    var vbox: VBox = VBox {
        translateY: bind headingText.boundsInLocal.height + 20
        translateX: 10
        content: [ nameVBox, projHBox, priorityVBox, reviewCheckBox,  notesVBox, sliderVbox]
        spacing: bind screenHeight/40
    }

    /**
     * Cancels the edit operation and rolls back any changes made to
     * the task details. Takes the control back to the task list.
     */
    var cancelButton: Button = Button {
        text: "Cancel"
        action: function() {
            if (controller.projectSpecific) {
                controller.showTasksList(task.category);
            } else {
                controller.showDefaultScreen();
            }
        }

        layoutInfo: LayoutInfo {
            width: buttonWidth
        }

        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                doneButton.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
                if (deleteButton.visible) {
                    deleteButton.requestFocus();
                } else {
                    slider.requestFocus();
                }
            } else if (ke.code == KeyCode.VK_ENTER or
                ke.code == KeyCode.VK_SPACE) {
                cancelButton.fire();
            }
        }
    }

    /**
     * Commits the changes to the underlying data model if an existing
     * task is edited. Otherwise adds a new task into the data model.
     */
    var doneButton: Button = Button {
        text: "Done"
        layoutInfo: LayoutInfo {
            width: buttonWidth
        }
        action: function(){
            if( nameVal != null) {
                var pt: TaskModel = TaskModel {
                    name: nameVal
                    category: if (catVal != null ) catVal else "{dataHandler.defProjCatName}"
                    percentCompletion: percentVal
                    reviewed: reviewVal
                    priority: priorityVal
                    notes: notesVal
                }
                if( task != null ) {
                    pt.key = task.key;
                    dataHandler.updateProjectTask(pt);
                } else {
                    var key = dataHandler.addProjectTask(pt);
                    pt.key = key;
                    task = pt;
                }
                if (controller.projectSpecific) {
                    controller.showTasksList(task.category);
                } else {
                    controller.showDefaultScreen();
                }
            } else if( nameVal == null or nameVal == "" ){
                showMessage("Please enter a task name.");
            } 
        }
        
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
    }

    /**
     * This button is shown only in the edit mode and not when adding new
     * tasks. When pressed, deletes the task from the underlying data model after
     * confirming with the user.
     */
    var deleteButton: Button = Button {
        text: "Delete"
        layoutInfo: LayoutInfo {
            width: buttonWidth
        }
        action: function() {
            if (task != null and task.key == -1) {
                deleteConfirmation(task.name);
            } else if (task.key != -1) {
                deleteConfirmation(dataHandler.getProjectTask(task.key).name);
            }
        }

        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                cancelButton.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
                slider.requestFocus();
            } else if (ke.code == KeyCode.VK_ENTER or
                ke.code == KeyCode.VK_SPACE) {
                deleteButton.fire();
            }
        }
        
        visible: bind if (task == null or task.key == -1) then false else true
    }

   /**
    * Holds the delete, cancel and done buttons buttons shown at the bottom.
    */
    var buttonHbox: HBox = HBox {
        translateY: bind screenHeight - (buttonHbox.boundsInLocal.height) - 7;
        translateX: 8
        spacing: 4
        content: [deleteButton, cancelButton, doneButton]
    }

   /**
    * Initializes the view that represents this screen.
    */
    protected override function createView(): Void {
        defControl = nameTextBox;
        view = Group {
            content: [headingText, vbox, buttonHbox]
        }
    }
}
