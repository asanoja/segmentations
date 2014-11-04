package fr.lip6.web.evaluation;

import java.awt.Component;
import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.ListCellRenderer;



class MyListRenderer extends JLabel implements ListCellRenderer {

    @Override
    public Component getListCellRendererComponent(JList list, Object value, int index, boolean isSelected, boolean cellHasFocus) {
        if (value instanceof String)  {
            setText((String) value);
        } else {
            ComboItem itemData = (ComboItem)value;
            try {
                setText((String)itemData.value);
            } catch (Exception e) {
                System.out.println("here");
            }
        }
        return this;
    }
}