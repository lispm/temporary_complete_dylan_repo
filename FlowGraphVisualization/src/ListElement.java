
public class ListElement implements Comparable {
	private String item;
	public int index;
	
	public ListElement (int index, String item) {
		this.item = item;
		this.index = index;
	}
	
	public int compareTo(Object o) {
		if (o instanceof ListElement) {
			ListElement other = (ListElement)o;
			return this.item.compareTo(other.toString());
		}
		return 0;
	}
	
	public String toString() {
		return item;
	}

}