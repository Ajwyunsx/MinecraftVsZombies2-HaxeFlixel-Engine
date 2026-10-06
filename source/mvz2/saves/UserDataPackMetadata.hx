// Ported from: Assets/Scripts/MVZ2/Saves/UserDataPackMetadata.cs
package mvz2.saves;

import pvzengine.base.Log;
import pvzengine.base.MissingSerializeDataException;

class UserDataPackMetadata {

    public function new(username:String) {
        this.username = username;
    }
    public function ToSerializable():SerializableUserDataPackMetadata {
        return {
            username: username
        };
    }
    public static function FromSerializable(seri:SerializableUserDataPackMetadata):UserDataPackMetadata {
        if (seri.username == null || seri.username.length == 0) {
            Log.LogException(MissingSerializeDataException.Property("username"));
            return null;
        }
        return new UserDataPackMetadata(seri.username);
    }
    public var username:String;
}

// [Serializable]
typedef SerializableUserDataPackMetadata = {
    var username:String;
}
