/*
 * PasswordBox.fx
 *
 * Created on 27/07/2009, 10:23:30
 */

package projectmanager;

import javafx.scene.control.TextBox;
import javafx.scene.input.KeyEvent;

/**
 * @author Diogo Souza da Silva <manifesto@manifesto.blog.br>
 */


public class PasswordBox extends TextBox {

    public var password: String;

    var lastSize: Integer = 0 on replace {
        if(isMe == false) {
            isMe = true;
            text = "";
            while(text.length() < password.length()) {
                text = "{text}*";
            }
            isMe = false;
        }
    } ;
    var isMe: Boolean = false;
    
    override var text on replace {
        if(isMe == false) {
            isMe = true;
            password = text ;
            text = "";
            while(text.length() < password.length()) {
                text = "{text}*";
            }
            isMe = false;
        }
    }


    def getKey = function(k: KeyEvent):Void {
        isMe = true;
        var lastSize = password.length();
        var size = rawText.length();
        var pos = dot ;
        var dif = lastSize - size ;
        if (k.char == "*") {
            if(password.length() <= pos) {
                password = "{password.substring(0,pos - 1)}"
                           "*"
            } else {
                password = "{password.substring(0,pos - 1)}"
                           "*"
                           "{password.substring(pos)}";
            }
        } else if(pos > 0) {
            if(rawText.charAt(pos - 1) != "*".charAt(0)) {
                if(password.length() < pos ) {
                    password = "{password}"
                               "{String.valueOf(rawText.charAt(pos - 1))}"
                } else if(dif >0){
                    password = "{password.substring(0,pos - 1)}"
                               "{String.valueOf(rawText.charAt(pos - 1))}"
                               "{password.substring(pos + dif )}";
                    dif = 0;
               } else {
                    password = "{password.substring(0,pos - 1)}"
                               "{String.valueOf(rawText.charAt(pos - 1))}"
                               "{password.substring(pos - 1 )}";
               }
            }
        }
        if(dif > 0) {
            password = "{password.substring(0,pos)}"
                       "{password.substring(pos + dif)}";
        }
        text = "";
        while(text.length() < size) {
            text = "{text}*";
        }
        positionCaret(pos);
        isMe = false;
    };

    override var onKeyTyped = function(k: KeyEvent):Void {
        getKey(k);
    };


}