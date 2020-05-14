using Godot;
using System;
using System.Threading;

public class merge_sort : Node
{
	// Declare member variables here. Examples:
	// private int a = 2;
	// private string b = "text";

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
	}

//  // Called every frame. 'delta' is the elapsed time since the previous frame.
//  public override void _Process(float delta)
//  {
//      
//  }
	public object Merge_Sort(int[] array, int p, int r){
        if(p<r){
			int q = (p+r)/2;
			Merge_Sort(array, p, q);
			Merge_Sort(array, q+1, r);
			Merge(array, p, q, r);
		}
        return array;
	}

	public void Merge(int[] a, int p, int q, int r){
		int n1 = q-p+1;
		int n2 = r-q;
		int[] left = new int[n1+1];
		int[] right = new int[n2+1];

		//Used multiple times, more efficient to initialize once.
		int i=0;
		int j=0;

		for(i=1; i<=n1; i++){
			left[i-1] = a[p+i-1];
		}
		for(j=1; j<=n2; j++){
			right[j-1] = a[q+j];
		}
		left[n1] = int.MaxValue;
		right[n2] = int.MaxValue;
		i=0;
		j=0;
		for(int k=p; k<=r; k++){
			if(left[i]<=right[j]){
				a[k] = left[i];
				i++;
			} else {
				a[k] = right[j];
				j++;
			}
		}
	}
}
