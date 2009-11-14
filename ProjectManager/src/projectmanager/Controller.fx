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
* Controller.fx
 *
 * Created on Apr 27, 2009, 7:59:08 PM
 */

package projectmanager;
import javafx.scene.Node;

/**
 * Controller class that takes care of screen navigation. Screen navigation is
 * centralized and abstracted here and all the view classes rely on the
 * controller to proceed to the previous or next screen.
 *
 * This class also takes care of doing the necessary initializations when the user
 * navigates from one screen to the other.
 */
public class Controller {

    /**
     * A node added to the scene. Represents the currently shown content.
     */
    public var contents: Node;
    
    /**
     * Handle to the actual data.
     */
    public var dataHandler: DataHandler = new DataHandler;

    /**
     * Handle to Login view .
     */
    public var loginView: LoginView;

    /**
     * Handle to Task list view  that lists out all the tasks.
     */
    public var taskListView: TaskListView;

    /**
     * Handle to Task Editor View that lets the user modify the task details
     * or add a new task.
     */
    public var taskView: TaskEditorView;

    /**
     * Handle to the project list view that lists out all the projects.
     */
    public var projListView: ProjectListView;
    
    /**
     * Handle to the Project Editor View that lets the user modify the project
     * details or add a new project.
     */
    public var projView: ProjectEditorView;

    /**
     * Indicates whether task list view should list all the tasks
     * or the tasks applicable only for the specified project.
     */
    public var projectSpecific: Boolean = false;

    /**
     * Shows the initial login screen
     */
    public function showLoginScreen() {
        if (loginView == null) {
            loginView = LoginView { 
                controller: this
            };
        } 
        contents = loginView;
        loginView.defControl.requestFocus();
        projectSpecific = false;
    }

    /**
     * Shows the initial screen where all the tasks are listed out and
     * sorted alphabetically. Tasks are categorized based on the priority.
     */
    public function showDefaultScreen() {
        if (taskListView == null) {
            taskListView = TaskListView {
                controller: this
                projCat: ""
            };
        } else {
            taskListView.projCat = "";
            taskListView.buttonGroup.selectedButton = taskListView.allButton;
            taskListView.populateList(taskListView.buttonGroup.selectedButton);
        }
        contents = taskListView;
        taskListView.defControl.requestFocus();
        projectSpecific = false;
    }

    /**
     * Shows the list of tasks. If project cat is null or empty, all the tasks
     * are listed. Otherwise, tasks that belong to the chosen project cat will
     * be listed.
     */
    public function showTasksList(projCat: String) {
        if (taskListView == null) {
            taskListView = TaskListView {
                controller: this
                projCat: projCat
            };
            taskListView.buttonGroup.selectedButton = taskListView.allButton;
            taskListView.populateList(taskListView.buttonGroup.selectedButton, projCat);
        } else {
            taskListView.projCat = projCat;
            taskListView.buttonGroup.selectedButton = taskListView.allButton;
            taskListView.populateList(taskListView.buttonGroup.selectedButton, projCat);
        }
        contents = taskListView;
        taskListView.defControl.requestFocus();
        projectSpecific = true;
    }

    /**
     * Shows the Task Editor View screen and one can modify the task details
     * or move the task to a diff project category.
     * If taskModel is null, that indicates creation of a new task.
     */
    public function showTaskDetails(taskDetails: TaskModel) {
        if (taskView == null) {
            taskView = TaskEditorView {
                task: taskDetails
                controller: this
            };
        } else {
            taskView.task = taskDetails;
        }
        contents = taskView;
        taskView.defControl.requestFocus();
    }

    /**
     * This shows the Task Editor View with projCat field initialized
     * to the chosen project.
     */
    public function showTaskDetailsWithProjectCategory(taskDetails: TaskModel,
            projCat: ProjectModel ) {
        if (taskView == null) {
            taskView = TaskEditorView {
                task: taskDetails
                controller: this
            };
        }
        contents = taskView;
        taskView.defControl.requestFocus();
    }

    /**
     * Shows the list of available projects.
     */
    public function showProjectDetails () {
        if (projListView == null) {
            projListView = ProjectListView {
                chooseProject: false
                controller: this
            };
        } else {
            projListView.chooseProject = false;
            projListView.populateList();
        }
        contents = projListView;
        projListView.defControl.requestFocus();
    }

    /**
     * Shows the list of available projects but one can not add/modify/delete
     * the projects shown. At the most, user can just select the project.
     * This screen is typically opened from Task Editor View when the user wants
     * to move a task from one project to another.
     */
    public function showProjectsList( projTask: TaskModel,
                                chooseProject: Boolean ) {
        if (projListView == null) {
            projListView = ProjectListView {
                chooseProject: true
                task: projTask
                controller: this
            }
        } else {
            projListView.chooseProject = true;
            projListView.task = projTask
        }
        contents = projListView;
        projListView.defControl.requestFocus();
    }

    /**
     * This is invoked typically when the user clicks on the project name
     * hyperlink shown on top of the TaskListView screen. This function
     * opens up the Project Editor screen.
     */
    public function showProjectCategoryDetails(cat: ProjectModel):Void {
        if(cat != null) {
            if (projView == null) {
                projView = ProjectEditorView {
                    projCat: cat
                    controller: this
                }
            } else {
                projView.projCat = cat;
            }
            contents = projView;
        } else {
            if (projView == null) {
                projView = ProjectEditorView {
                    controller: this
                    projCat: null
                }
            } else {
                projView.projCat = null;
                projView.initializeProject(cat != null);
            }
            contents = projView;
        }
        projView.defControl.requestFocus();
    }
}
