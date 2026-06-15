<?php

namespace app\models\form;

use Yii;
use yii\base\Model;
use app\models\database\User;

class RegisterForm extends Model
{
    public $username;
    public $password;
    public $password_confirm;

    public function rules()
    {
        return [
            [['username', 'password', 'password_confirm'], 'required'],
            [['username'], 'string', 'min' => 3, 'max' => 64],
            [['username'], 'match', 'pattern' => '/^[a-zA-Z0-9_\-]+$/', 'message' => 'El nombre de usuario solo puede contener letras, números, guiones y guiones bajos.'],
            [['username'], 'unique', 'targetClass' => User::class, 'targetAttribute' => 'username', 'message' => 'Este nombre de usuario ya está en uso.'],
            [['password'], 'string', 'min' => 8],
            [['password_confirm'], 'compare', 'compareAttribute' => 'password', 'message' => 'Las contraseñas no coinciden.'],
        ];
    }

    public function attributeLabels()
    {
        return [
            'username' => 'Nombre de usuario',
            'password' => 'Contraseña',
            'password_confirm' => 'Confirmar contraseña',
        ];
    }

    public function register()
    {
        if (!$this->validate()) {
            return false;
        }

        $user = new User();
        $user->username = $this->username;
        $user->setPassword($this->password);
        $user->generateAuthKey();
        $user->status = 10;

        return $user->save();
    }
}
