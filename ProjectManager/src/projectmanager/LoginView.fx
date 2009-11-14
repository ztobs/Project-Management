/* 
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER
 * Copyright 2009 Diogo Souza da Silva <Manifesto@manifesto.blog.br>
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
 * LoginView.fx
 *
 * Created on Oct 17, 2009, 00:44:00 PM
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
public class LoginView extends AppView {
   

    var buttonWidth = (screenWidth - 10);
    
    var nameLabel: Label = Label {
        text: "Username"
        textFill: Color.WHITE
    }

    var usernameTextBox: TextBox = TextBox {
        columns: 25
        text: ""
        promptText: "username"
        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                passwordTextBox.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
                doneButton.requestFocus();
            }
        }
    }    
    var passwordTextBox: PasswordBox = PasswordBox {
        columns: 25
        text: ""
        promptText: "password"
        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                doneButton.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
                usernameTextBox.requestFocus();
            }
        }
    }        
    var passwordLabel: Label = Label {
        text: "Password"
        textFill: Color.WHITE
    }

    var doneButton: Button = Button {
        text: "Done"
        layoutInfo: LayoutInfo { width: bind buttonWidth }
        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                usernameTextBox.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
                passwordTextBox.requestFocus();
            } else if (ke.code == KeyCode.VK_ENTER or
                ke.code == KeyCode.VK_SPACE) {
                doneButton.fire();
            }
        }
        action: function() {
            if (usernameTextBox.text == null or usernameTextBox.text == "") {
                showMessage("Please enter a username.");
                return;
            }
            if (passwordTextBox.text == null or passwordTextBox.text == "") {
                showMessage("Please enter a password.");
                return;
            }
            dataHandler.login(usernameTextBox.text,passwordTextBox.password,
                    function(s: Integer): Void {
                        if(s == 1) {
                            controller.showDefaultScreen();
                        } else if(s == -1) {
                            showMessage("Oops, could not login.");
                        } else if(s == 0) {
            showProgress("Data");
                        }
                    });
            showProgress("Data");
        }
    }

    var headingText: Label = Label {
        font: Font {
            name: "Bitstream Vera Sans Bold"
            size: 14
        }
        text: "Login"
        translateX: bind (screenWidth - headingText.boundsInLocal.width) / 2.0
        translateY: 10
        textFill: Color.WHITE
        width: bind (5.0/6.0 * screenWidth)
    }

    var nameVbox: VBox = VBox {
        content: [nameLabel, usernameTextBox]
        spacing: 5
    }

    var noteVbox:VBox = VBox {
        content: [passwordLabel, passwordTextBox]
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
        content: [doneButton]
        spacing: 2
    }

   
    protected override function createView(): Void {
        defControl = usernameTextBox;
        view = Group {
            content: [headingText, nameNoteVBox, buttonBox]
        }
    }
}
