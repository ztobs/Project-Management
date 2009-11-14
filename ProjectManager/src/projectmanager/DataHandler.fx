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
 * DataHandler.fx
 *
 * Created on Apr 24, 2009, 5:54:56 PM
 */

package projectmanager;

import projectmanager.ProjectModel;
import projectmanager.TaskModel;
import javafx.io.http.HttpRequest;
import java.io.InputStream;
import java.lang.Exception;
import javafx.io.http.HttpHeader;
import java.lang.StringBuffer;
import java.io.OutputStream;
import javafx.data.feed.atom.AtomTask;
import javafx.data.feed.atom.Entry;
import javafx.data.feed.atom.Feed;
import javafx.data.pull.PullParser;
import javafx.data.pull.Event;
import java.io.ByteArrayInputStream;

/**
 * DataHandler which takes care of the data manipulation and data initialization.
 * This class takes care of deleting the data, adding new data, updating the
 * existing data and synchronizing the corresponding view when the data changes.
 *
 * Takes care of task as well as project data and also populates the mock data.
 * This class can be suitably enhanced when interfacing the real-data from
 * the data base or from a web source.
 */
public var projectCategories: ProjectModel[];
public var projectTasks: TaskModel[];

public class DataHandler {

    /**
     * Used as the primary key for task schema within the data model.
     */
    var taskKeyGenerator: Integer  = 100;

    /**
     * Used as the primary key for project schema within the data model.
     */
    var projKeyGenerator: Integer  = 100;

    /**
     * Used to synchronize the project view with the data model.
     */
    public var updateProjectView: Boolean = false;

    /**
     * Used to synchronize the task view with the data model.
     */
    public var updateTaskView: Boolean = false;

    /**
     * Identifies the default project category name to be used
     * when the task is not assigned to any project explicitly.
     */
    public var defProjCatName: String = "Unassigned";

    /**
     * Google Authentication key
     */
    public var authHeader: HttpHeader ;

    /**
     * Name of the sheet to use
     */
    public def sheet: String  = "JavaFxProjectManagerDB";
    /**
     * Sheet link
     */
    public var sheetLink: String  = "";

public function login(user: String, pass: String,f: function(b: Integer): Void){
        HttpRequest {
            location: "https://www.google.com/accounts/ClientLogin"
            method: HttpRequest.POST
            headers: HttpHeader { name: HttpHeader.CONTENT_TYPE, value: "application/x-www-form-urlencoded" }
            onInput: function(is: InputStream) {
                def sb: StringBuffer = StringBuffer{};
                var c:Integer = is.read();
                while(c != -1) {
                    sb.append(c as Character);
                    c = is.read();
                }
                is.close();
                def str: String = sb.toString().trim();
                def chars: Character[] = str.toCharArray();
                var sb2:StringBuffer = new StringBuffer();
                def EQ  = "=".toCharArray()[0];
                def NL = "\n".toCharArray()[0];
                var got = false;
                var auth: String ;
                for(ch in chars) {
                    if(ch == NL) {
                        if(sb.toString().startsWith("Auth=")) {
                            break;
                        } else {
                            sb2 = new StringBuffer();
                        }
                    }
                    sb2.append(ch);
                }
                auth = sb2.toString().substring(6);
                authHeader = HttpHeader { name: "Authorization", value: "GoogleLogin auth={auth}" }
            }
            onOutput: function(out: OutputStream) {
               def sb: StringBuffer = new StringBuffer();
               sb.append("accountType=");
               sb.append("HOSTED_OR_GOOGLE");
               sb.append("&Email=");
               sb.append(user);
               sb.append("&Passwd=");
               sb.append(pass);
               sb.append("&service=");
               sb.append("writely");
               sb.append("&source=");
               sb.append("Manifesto.blog.br-ProjectManager-JavaFx");
               out.write(sb.toString().getBytes());
               out.close();
            }
            onError: function(is: InputStream) {
                def sb: StringBuffer = StringBuffer{};
                var c:Integer = is.read();
                while(c != -1) {
                    sb.append(c as Character);
                    c = is.read();
                }
                is.close();
                var str: String = sb.toString().trim();
                println(str);
                f(-1);
            }
            onDone: function() {
                f(0);
                loadDocs(f);
            }
            onException: function(e: Exception) {
               e.printStackTrace();
               f(-1);
            }
            onStart: function() {
                f(0);
            }
        }.start();

    }

    public function createDoc(f: function(b: Integer): Void) {
        HttpRequest {
            location: "http://docs.google.com/feeds/default/private/full"
            method: HttpRequest.POST
            headers: [ 
                        authHeader,
                        HttpHeader {
                            name: HttpHeader.CONTENT_TYPE
                            value: "text/plain"
                        } ,
                        HttpHeader { 
                            name: "slug"
                            value: sheet
                        },
                        HttpHeader{name:"GData-Version",value:"3.0"}
                     ]
            onInput: function(is: InputStream) {
                def sb: StringBuffer = StringBuffer{};
                var c:Integer = is.read();
                while(c != -1) {
                    sb.append(c as Character);
                    c = is.read();
                }
                is.close();
                def str: String = sb.toString().trim();
            }
            onOutput: function(out: OutputStream) {
               out.write("[]".getBytes());
               out.close();
            }
            onError: function(is: InputStream) {
                def sb: StringBuffer = StringBuffer{};
                var c:Integer = is.read();
                while(c != -1) {
                    sb.append(c as Character);
                    c = is.read();
                }
                is.close();
                var str: String = sb.toString().trim();
                println(str);
                f(-1);
            }
            onDone: function(): Void {
               loadDocs(f);
            }
            onException: function(e: Exception) {
               e.printStackTrace();
            }
            onStart: function() {
                f(0);
            }

        }.start();
    }

    public function loadDocs(f: function(b: Integer): Void): Void{
        var link: String ;
        def a:AtomTask = AtomTask  {
            headers: [authHeader, HttpHeader{name:"GData-Version",value:"3.0"}]
            interval: 30s
            location:"http://docs.google.com/feeds/default/private/full?title={sheet}&title-exact=true"
            onEntry: function(entry: Entry) {
                if(entry.title.text == sheet) {
                    link = entry.id.uri ;
                }
            }
            onStart: function() {
                f(0);
            }
            onException: function(ex: Exception) {
                ex.printStackTrace();
                f(-1);
            }
            onFeed: function(feed: Feed) {
            }
            onDone: function() {
                if(link.length() < 1) {
                    createDoc(f);
                } else {
                    sheetLink = link;
                    f(0);
                    loadData(f);
                }
            }
        };
        a.poll();
    }

    public function loadData(f: function(status: Integer): Void): Void {
       var tasks: TaskModel[];
       var projects: ProjectModel[];
       def of: Integer = sheetLink.lastIndexOf("/") + 1;
       def id: String = sheetLink.substring(of);
       HttpRequest {
           headers: [authHeader, HttpHeader{name:"GData-Version",value:"3.0"}]
           location: "http://docs.google.com/feeds/download/documents/Export?docID={id}&exportFormat=txt"
           onStart: function() {
               f(0);
           }
           onInput: function(is: InputStream) {
                def sb: StringBuffer = StringBuffer{};
                var c:Integer = is.read();
                while(c != -1) {
                    sb.append(c as Character);
                    c = is.read();
                }
                is.close();
                def str: String = sb.toString().substring(sb.toString().indexOf("[")).trim();
                PullParser {
                    documentType: PullParser.JSON
                    input: new ByteArrayInputStream(str.getBytes());
                    onEvent: function(e: Event) {
                        if(e.type == PullParser.START_ELEMENT) {
                            insert TaskModel{} before tasks[0];
                        } else if(e.type == PullParser.TEXT) {
                            if(e.name == "category") {
                                tasks[0].category = e.text ;
                                var isNew = true;
                                for(p in projects) {
                                    if(p.name == e.text) {
                                        isNew = false;
                                        break;
                                    }
                                }
                                if(isNew) insert ProjectModel {
                                        name: e.text;
                                } into projects ;
                            } else if(e.name == "name"){
                                tasks[0].name = e.text ;
                            } else if(e.name == "notes") {
                                tasks[0].notes = e.text ;
                            } else if(e.name == "percentCompletion"){
                                tasks[0].percentCompletion = Number.parseFloat(e.text) ;
                            } else if(e.name == "priority"){
                                tasks[0].priority = Number.parseFloat(e.text) ;
                            } else if(e.name == "reviewed"){
                                    if(e.text == "true") {
                                        tasks[0].reviewed = true ;
                                    } else {
                                        tasks[0].reviewed =false ;
                                    }
                            } else if(e.name == "key"){
                                tasks[0].key = Integer.parseInt(e.text) ;
                            } else if(e.name == "id"){
                                tasks[0].id = e.text ;
                            }
                        }
                    }
                }.parse();

            }
            onError: function(is: InputStream) {
                def sb: StringBuffer = StringBuffer{};
                var c:Integer = is.read();
                while(c != -1) {
                    sb.append(c as Character);
                    c = is.read();
                }
                is.close();
                var str: String = sb.toString().trim();
                println(str);
                f(-1);
            }
            onDone: function(): Void {
                addProjectCategories(projects);
                addProjectTasks(tasks);
                f(1);
            }
            onException: function(e: Exception) {
               e.printStackTrace();
            }
       }.start();

    }

    public function save(f: function(b: Integer)): Void {
        
       def of: Integer = sheetLink.lastIndexOf("/") + 1;
       def id: String = sheetLink.substring(of);
        HttpRequest {
            location: "http://docs.google.com/feeds/default/media/{id}"
            method: HttpRequest.PUT
            headers: [
                        authHeader,
                        HttpHeader {
                            name: HttpHeader.CONTENT_TYPE
                            value: "text/plain"
                        } ,
                        HttpHeader {
                            name: "If-Match"
                            value: "*"
                        },
                        HttpHeader {
                            name: "slug"
                            value: sheet
                        },
                        HttpHeader{name:"GData-Version",value:"3.0"}
                     ]
            onInput: function(is: InputStream) {
                def sb: StringBuffer = StringBuffer{};
                var c:Integer = is.read();
                while(c != -1) {
                    sb.append(c as Character);
                    c = is.read();
                }
                is.close();
                def str: String = sb.toString().trim();
            }
            onOutput: function(out: OutputStream) {
               def sb: StringBuffer = new StringBuffer();
               sb.append("[");
               for(t in projectTasks) {
                   sb.append("\n\{");
                   sb.append('\n\t"category":"{t.category}"');
                   sb.append('\n\t,"name":"{t.name}"');
                   sb.append('\n\t,"notes":"{t.notes}"');
                   sb.append('\n\t,"percentCompletion":"{t.percentCompletion}"');
                   sb.append('\n\t,"priority":"{t.priority}"');
                   sb.append('\n\t,"reviewed":"{t.reviewed}"');
                   sb.append('\n\t,"key":"{t.key}"');
                   sb.append('\n\t,"id":"{t.id}"');
                   sb.append("\n\},");
               }
               def ls: Integer = sb.toString().lastIndexOf(",");
               if(ls > 0) {
                    sb.deleteCharAt(ls);
               }
               sb.append("]");
               out.write(sb.toString().getBytes());
               out.close();
            }
            onError: function(is: InputStream) {
                def sb: StringBuffer = StringBuffer{};
                var c:Integer = is.read();
                while(c != -1) {
                    sb.append(c as Character);
                    c = is.read();
                }
                is.close();
                var str: String = sb.toString().trim();
                println(str);
                f(1);
            }
            onDone: function(): Void {
                f(1);
            }
            onException: function(e: Exception) {
               e.printStackTrace();
            }
            onStart: function() {
                f(0);
            }

        }.start();
    }

    /**
     * Get all the project categories.
     */
    public function getProjectCategory(): ProjectModel[] {
        return projectCategories;
    }

    /**
     * Get the task primary key for adding a new task.
     */
    function getTaskKey(): Integer {
        return taskKeyGenerator ++;
    }

    /**
     * Get the project primary key for adding a new project.
     */
    function getProjectKey(): Integer {
        return projKeyGenerator ++;
    }

    /**
     * Add a new task into the data model.
     */
    public function addProjectTask(pt: TaskModel):Integer {
        updateTaskView = false;
        var i: Integer = 0; var pos: Integer = 0;
        var key = getTaskKey();
        pt.key = key;
        if(projectTasks.size() > 0) {
            
            for(projTask in projectTasks){
                if (projTask.name == null or projTask.name == "") {
                    pos = i;
                    break;
                }
                   
                if(pt.name.compareTo(projTask.name) > 0 ) {
                    i++;
                    continue;
                } else if(pt.name.compareTo(projTask.name) <= 0) {
                    pos = i;
                    break;
                }
            }
            if(i == 0 ){
               insert pt before projectTasks[0];
            } else if( pos == 0 ){
                insert pt into projectTasks;
            } else {
                insert pt before projectTasks[pos];
            }

        } else {
            insert pt into projectTasks;
        }
        updateTaskView = true;
        return key;
    }

    /**
     * Add multiple tasks into the data model.
     */
    public function addProjectTasks(tasks: TaskModel[]):Void {
        for (task in tasks) {
            addProjectTask(task);
        }
    }

    /**
     * Add a new project category into the data model.
     */
    public function addProjectCategory(pc: ProjectModel): Boolean {
        updateProjectView = false;
        for (cat in projectCategories) {
            if (cat.name.equalsIgnoreCase(pc.name)) {
                return false;
            }
        }

        var i: Integer = 0; var pos: Integer = 0;
        var key = getProjectKey();
        pc.key = key;
        if( projectCategories.size() > 0 ) {
            for( projCate in projectCategories ){
                 if (projCate.name == null or projCate.name == "") {
                    pos = i;
                    break;
                }
                if( pc.name.compareTo(projCate.name) > 0 ) {
                    i++;
                    continue;
                } else if(pc.name.compareTo(projCate.name) <= 0) {
                    pos = i;
                    break;
                }
            }
            if(i == 0 ){
               insert pc before projectCategories[0];
            } else if( pos == 0 ){
                insert pc into projectCategories;
            } else {
                insert pc before projectCategories[pos];
            }
        } else {
            insert pc into projectCategories;
        }
        updateProjectView = true;
        return true;
    }

    /**
     * Add a sequence of project categories into the data model.
     */
    public function addProjectCategories(cats: ProjectModel[]):Void {
        for (cat in cats) {
            addProjectCategory(cat);
        }
    }

    /**
     * Update an existing project category.
     */
    public function updateProjectCategory(pCat: ProjectModel): Integer {
        for (cat in projectCategories) {
            if (cat.key != pCat.key and cat.name.equalsIgnoreCase(pCat.name)) {
                // Indicates there is another project with same name
                return 1;
            }
        }
        for(projCat in projectCategories) {
            if(projCat.key == pCat.key) {
                if (projCat.name != pCat.name) {
                    for (tasks in projectTasks) {
                        if (tasks.category.equalsIgnoreCase(projCat.name)) {
                            // Indicates there are some tasks using this project
                            return 2;
                        }
                    }
                }

                delete projCat from projectCategories;
                break;
            }
        }
        addProjectCategory(pCat);
        return 0;
    }

    /**
     * Update an existing task details.
     */
    public function updateProjectTask(pTask: TaskModel){
        for(projTas in projectTasks) {
            if(projTas.key == pTask.key) {
                delete projTas from projectTasks;
                break;
            }
        }
        addProjectTask(pTask);
    }

    /**
     * Get all the task details.
     */
    public function getProjectTasks(): TaskModel[] {
        return projectTasks;
    }

    /**
     * Get all the tasks based on the priority.
     */
    public function getProjectTasks(pr: Integer): TaskModel[] {
        var projTsks: TaskModel[];
        for(proj in projectTasks){
            if( proj.priority == pr or proj.name == null) {
                insert proj into projTsks;
            }
        }
        return projTsks;
    }

    /**
     * Get the task details for the given task name.
     */
    public function getProjectTask(projName: String): TaskModel {
        for(proj in projectTasks){
            if( proj.name == projName) {
                return proj;
            }
        }
        return null;
    }

    /**
     * Get the task details based on the primary key identifier.
     */
    public function getProjectTask(key: Integer): TaskModel {
        for (proj in projectTasks) {
            if (proj.key == key) {
                return proj;
            }
        }
        return null;
    }

    /**
     * Get all the project category names.
     */
    public function getProjectCategoriesNames(): String[] {
        var prCatNames: String[];
        for(projCat in projectCategories) {
            insert projCat.name into prCatNames;
        }
        return prCatNames;
    }

    /**
     * Get the project details for the given project name
     */
    public function getProjectCategory(catName: String): ProjectModel {
        for(projCat in projectCategories) {
            if( projCat.name == catName )
            return projCat;
        }
        return null;
    }

    /**
     * Get the project details based on the primary key identifier.
     */
    public function getProjectCategory(key: Integer): ProjectModel {
        for(projCat in projectCategories) {
            if( projCat.key == key )
            return projCat;
        }
        return null;
    }

    /**
     * Get all the task names.
     */
    public function getProjectTasksNames(): String[] {
        var prTNames: String[];
        for(projTask in projectTasks) {
            insert projTask.name into prTNames;
        }
        return prTNames;
    }

    /**
     * Get all the task names that belong to a specified project category.
     */
    public function getProjectTasksNames(projCat: String): String[] {
        var prTNames: String[];
        for(projTask in projectTasks) {
            if (projTask.category == projCat) {
                insert projTask.name into prTNames;
            }
        }
        return prTNames;
    }

    /**
     * Get the task names based on the priority.
     */
    public function getProjectTasksNames(pr: Integer): String[] {
        var prTNames: String[];
        for(projTask in projectTasks) {
            if( projTask.priority == pr or projTask.name == null ) {
                insert projTask.name into prTNames;
            }
        }
        return prTNames;
    }

    /**
     * Get the task names for the given priority and project name.
     */
    public function getProjectTasksNames(pr: Integer, projCat: String): String[] {
        var prTNames: String[];
        for(projTask in projectTasks) {
            if (projTask.category == projCat) {
                if( projTask.priority == pr or projTask.name == null ) {
                    insert projTask.name into prTNames;
                }
            }
        }
        return prTNames;
    }

    /**
     * Delete the given project category if no tasks are defined for the project.
     */
    public function deleteProjectCategory(pc: ProjectModel): Boolean {
        deleteProjectCategory(pc.key);
    }

    /**
     * Delete the project category based on the primary key identifier.
     */
    public function deleteProjectCategory(key: Integer) {
        updateProjectView = false;
        if(projectCategories.size() > 0){
            for( pcat in projectCategories) {
                if(pcat.key == key) {
                    for (task in projectTasks) {
                        if (task.category == pcat.name) {
                            return false;
                        }
                    }
                    delete pcat from projectCategories;
                    updateProjectView = true;
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * Delete the project category based on the category name.
     */
    public function deleteProjectCategory(catName: String) {
        updateProjectView = false;
        if(projectCategories.size() > 0){
            for( pcat in projectCategories) {
                if(pcat.name == catName) {
                    for (task in projectTasks) {
                        if (task.category == pcat.name) {
                            return false;
                        }
                    }
                    delete pcat from projectCategories;
                    updateProjectView = true;
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * Delete the given task.
     */
    public function deleteProjectTask(pt: TaskModel): Void {
        updateTaskView = false;
        if(projectTasks.size() > 0){
            for( pTask in projectTasks) {
                if(pTask.key == pt.key) {
                    delete pTask from projectTasks;
                    updateTaskView = true;
                    break;
                }
            }
        }
    }

    /**
     * Delete the task denoted by the task name.
     */
    public function deleteProjectTask(ptName: String): Void {
        updateTaskView = false;
        if(projectTasks.size() > 0){
            for( pTask in projectTasks) {
                if(pTask.name == ptName) {
                    delete pTask from projectTasks;
                    updateTaskView = true;
                    break;
                }
            }
        }
    }
}
