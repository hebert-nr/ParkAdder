using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ParkAdder
{
    public class HiddenID
    {
    
        string displayValue;
        string hiddenValue;

        //Constructor
        public HiddenID (string d, string h)
        {
           displayValue = d;
           hiddenValue = h;
        }

        //Accessor
        public string HiddenValue
        {
               get
            {
               return hiddenValue;
            }
        }
              
        //Override ToString method
        public override string ToString()
        {
            return displayValue;
        }
    }
}