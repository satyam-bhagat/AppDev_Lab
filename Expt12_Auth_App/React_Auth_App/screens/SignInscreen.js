import { signInWithEmailAndPassword } from 'firebase/auth';
import { useState } from 'react';
import { Button, Text, TextInput, View } from 'react-native';
import GoogleButton from '../components/GoogleButton';
import { auth } from '../config/firebaseconfig';

export default function SignInScreen({ navigation }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const signin = async () => {
    try {
      await signInWithEmailAndPassword(auth, email.trim(), password);
    } catch (err) {
      alert(err.message);
    }
  };

  return (
    <View style={{ padding: 20 }}>
      <TextInput placeholder="Email" value={email} onChangeText={setEmail} autoCapitalize="none" keyboardType="email-address" style={{borderBottomWidth:1, marginBottom:12}} />
      <TextInput placeholder="Password" value={password} onChangeText={setPassword} secureTextEntry style={{borderBottomWidth:1, marginBottom:12}} />
      <Button title="Sign In" onPress={signin} />
      <Text style={{marginTop:12}} onPress={()=>navigation.navigate('ForgotPassword')}>Forgot password?</Text>
      <Text style={{marginTop:12}} onPress={()=>navigation.navigate('SignUp')}>Create account</Text>

      <View style={{marginTop:20}}>
        <GoogleButton />
      </View>

      <View style={{marginTop:20}}>
        <Button title="Phone Login (info)" onPress={()=>navigation.navigate('PhoneAuth')} />
      </View>
    </View>
  );
}
