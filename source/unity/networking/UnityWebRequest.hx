package unity.networking;

import haxe.Http;
import unity.AsyncOperation;
import unity.networking.WWWForm;

// Minimal UnityEngine.Networking.UnityWebRequest shim (backed by haxe.Http).
class UnityWebRequest {
    public var url:String;
    public var timeout:Int = 0;
    public var result:Result = Result.InProgress;
    public var error:String = "";
    public var downloadHandler:DownloadHandler;
    public var uploadHandler:Dynamic;

    private var http:Http;

    public function new(url:String) {
        this.url = url;
        downloadHandler = new DownloadHandler();
    }

    public static function Post(url:String, form:WWWForm):UnityWebRequest {
        var request = new UnityWebRequest(url);
        request.http = new Http(url);
        request.http.setPostData([for (k in form.fields.keys()) k + "=" + StringTools.urlEncode(form.fields.get(k))].join("&"));
        request.http.setHeader("Content-Type", "application/x-www-form-urlencoded");
        return request;
    }
    public static function Get(url:String):UnityWebRequest {
        var request = new UnityWebRequest(url);
        request.http = new Http(url);
        return request;
    }

    public function SendWebRequest():AsyncOperation {
        var op = new AsyncOperation();
        if (http == null) {
            result = Result.Success;
            op.complete();
            return op;
        }
        http.onData = function(data:String) {
            downloadHandler.text = data;
            downloadHandler.data = haxe.io.Bytes.ofString(data);
            result = Result.Success;
            op.complete();
        };
        http.onError = function(message:String) {
            error = message;
            result = Result.ConnectionError;
            op.complete();
        };
        http.request(false);
        return op;
    }

    public function Dispose():Void {}
    public function Abort():Void {}
    public function SetRequestHeader(name:String, value:String):Void {
        if (http != null) http.setHeader(name, value);
    }

    public static function get_text(request:UnityWebRequest):String return request.downloadHandler.text;
    public var isDone(get, never):Bool;
    function get_isDone():Bool return result != Result.InProgress;
}

enum abstract Result(Int) {
    var InProgress = 0;
    var Success = 1;
    var ConnectionError = 2;
    var ProtocolError = 3;
    var DataProcessingError = 4;
}

class DownloadHandler {
    public var text:String = "";
    public var data:haxe.io.Bytes;
    public function new() {}
    public function ToString():String return text;
}
