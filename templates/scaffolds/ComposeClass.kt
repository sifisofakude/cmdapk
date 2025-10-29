package __PACKAGE_NAME__

import androidx.compose.runtime.Composable
import androidx.compose.material3.Text
import androidx.compose.ui.Modifier

@Composable
fun GreetingScreen(
  name: String,
  modifier: Modifier = Modifier
)  {
  Text(text = "Hello, $name",modifier = modifier)
}
