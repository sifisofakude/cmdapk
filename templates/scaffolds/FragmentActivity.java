package __PACKAGE_NAME__;

import android.os.Bundle;

import android.view.View;
import android.view.ViewGroup;
import android.view.LayoutInflater;

import androidx.fragment.app.Fragment;

public class __CLASS_NAME__ extends Fragment  {
  @Override
  public View onCreateView(LayoutInflater inflater,ViewGroup container,Bundle instanceState)	{
		return inflater.inflate(R.layout.__LAYOUT_NAME__,container,false);
	}
	
	@Override
	public void onViewCreated(View view, Bundle instanceState)	{}
}
