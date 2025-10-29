package __PACKAGE_NAME__;

import android.os.Bundle;

import android.view.View;
import android.view.ViewGroup;
import android.view.LayoutInflater;

import androidx.fragment.app.Fragment;

public class __CLASS_NAME__ : Fragment()  {
  override fun onCreateView(inflater: LayoutInflater? ,container: ViewGroup? ,savedInstanceState: Bundle?): View	{
		return inflater.inflate(R.layout.__LAYOUT_NAME__,container,false);
	}
	
	override fun onViewCreated(view: View?, savedInstanceState: Bundle?)	{}
}
