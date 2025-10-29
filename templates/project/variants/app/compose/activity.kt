package __PACKAGE_NAME__

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.runtime.Composable
import androidx.compose.material3.Text
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview

class __ACTIVITY_NAME__ : ComponentActivity() {
  override fun onCreate(savedInstanceState: Bundle?)  {
    super.onCreate(savedInstanceState)
    setContent  {
      GreetingScreen()
    }
  }
  
  @Composable
  fun GreetingScreen()  {
    Text(text = "Hello from __APP_NAME__")
  }
  
  @Preview(showBackground = true)
  @Composable
  fun PreviewGreeting() {
    GreetingScreen()
  }
}
