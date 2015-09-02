using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Data.SqlClient;

namespace ParkAdder
{
    public partial class Form1 : Form
    {

<<<<<<< HEAD
        SqlConnection con = new SqlConnection("Data source = localhost;Initial Catalog=PPF;Integrated Security=True ");
=======
        SqlConnection con = new SqlConnection("Data source = localhost;Initial Catalog=thePPF;Integrated Security=True ");
>>>>>>> b7e3c4ccf1c213a55ebeab0adc9a01c3b073719c

        public Form1()
        {
            InitializeComponent();
        }

        private void Exit_Click(object sender, EventArgs e)
        {
            con.Close();
            this.Close();
        }

        private void Form1_Shown(object sender, EventArgs e)
        {
        }

        void btnAddFeature_Click(object sender, EventArgs e)
        {

            try
            {
                con.Open();


                foreach (System.Data.DataRowView drv in lboFeature.SelectedItems)
                {

                    int featureID = int.Parse(drv.Row[lboFeature.ValueMember].ToString());
<<<<<<< HEAD
                    SqlCommand addFeat = new SqlCommand("Insert Into FeaturesAtPark (CAST(PID AS NVARCHAR(10)) + '.' + (CAST(FID AS NVARCHAR(10)) AS Combine Values("
                                                        + cboName.SelectedValue + ", " + featureID + ")");
                   
                    SqlCommand stop = new SqlCommand("FeatureDenied", con);

                    if (stop.Parameters.Contains((Convert.ToString(cboName.SelectedValue))) || stop.Parameters.Contains(Convert.ToString((featureID))))
                    {
                        MessageBox.Show("Feature already listed in park.");
                    }
                    else
                    {
                        addFeat.Connection = con;
                        addFeat.ExecuteNonQuery();
                    }
=======

                   
                    SqlCommand addFeat = new SqlCommand("IF NOT EXISTS (Select PID, FID From FeaturesAtPark Where PID = " + cboName.SelectedValue + " AND FID = " + featureID + ") Insert Into FeaturesAtPark (PID,FID) Values("
                                                        + cboName.SelectedValue + ", " + featureID + ")");

                    addFeat.Connection = con;
                    addFeat.ExecuteNonQuery();
                    
>>>>>>> b7e3c4ccf1c213a55ebeab0adc9a01c3b073719c
                }

                con.Close();
            }
            catch (SqlException ex)
            {
                MessageBox.Show(ex.Message, Application.ProductName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                Application.Exit();
            }

        }


        private void Form1_Load(object sender, EventArgs e)
        {
<<<<<<< HEAD
            SqlCommand command = new SqlCommand("SELECT ParkID, ParkName FROM PPF.dbo.Park", con);
            SqlCommand comFeat = new SqlCommand("Select FeatureID, FeatureName FROM PPF.dbo.Feature", con);
=======
            SqlCommand command = new SqlCommand("SELECT ParkID, ParkName FROM thePPF.dbo.Park", con);
            SqlCommand comFeat = new SqlCommand("Select FeatureID, FeatureName FROM thePPF.dbo.Feature", con);
>>>>>>> b7e3c4ccf1c213a55ebeab0adc9a01c3b073719c

            try
            {

                con.Open();

                SqlDataAdapter adap = new SqlDataAdapter(command);
                SqlDataAdapter adapFeat = new SqlDataAdapter(comFeat);
                DataTable dt = new DataTable();
                DataTable dtFeat = new DataTable();
                adap.Fill(dt);
                adapFeat.Fill(dtFeat);

                cboName.DataSource = dt;
                cboName.DisplayMember = "ParkName";
                cboName.ValueMember = "ParkID";

                lboFeature.DataSource = dtFeat;
                lboFeature.DisplayMember = "FeatureName";
                lboFeature.ValueMember = "FeatureID";

                con.Close();
            }
            catch (SqlException ex)
            {
                MessageBox.Show(ex.Message, Application.ProductName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                Application.Exit();
            }

        }


        private void cboName_SelectedIndexChanged(object sender, EventArgs e)
        {
        }

        private void btnClear_Click(object sender, EventArgs e)
        {
            txtAddAddress.Clear();
            txtAddName.Clear();
            txtAddCity.Clear();
            txtAddZip.Clear();
            txtCounty.Clear();
        }


        //checks for information, opens connection to database and adds a new park with its information to the park table.
        private void btnAddPark_Click(object sender, EventArgs e)
        {
            try
            {

                con.Open();

                //Add items to table Park, run validation 
                if (withErrors() == true)
                {
                    MessageBox.Show("Must fill in all boxes before adding");

                }
                else
                {
                    SqlCommand cmd = new SqlCommand("insert into Park(ParkName, StreetAddress, City, County, ZipCode) values(@name, @address, @city, @county, @zip)", con);

                    cmd.Parameters.AddWithValue("@name", txtAddName.Text);
                    cmd.Parameters.AddWithValue("@address", txtAddAddress.Text);
                    cmd.Parameters.AddWithValue("@city", txtAddCity.Text);
                    cmd.Parameters.AddWithValue("@county", txtCounty.Text);
                    cmd.Parameters.AddWithValue("@zip", txtAddZip.Text);

                    SqlDataReader reader;
                    reader = cmd.ExecuteReader();
                    MessageBox.Show("Saved");
                    while (reader.Read())
                    {

                    }
                    con.Close();
                }
            }

            catch (SqlException ex)
            {
                MessageBox.Show(ex.Message, Application.ProductName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                Application.Exit();

            }

        }


        //Checks for txtboxes to have at least 1 character in them
        private bool withErrors()
        {
            if (txtAddName.Text.Trim() == String.Empty)
            {
                return true;
            }
            if (txtAddAddress.Text.Trim() == String.Empty)
            {
                return true;
            }
            if (txtAddCity.Text.Trim() == String.Empty)
            {
                return true;
            }
            if (txtAddZip.Text.Trim() == String.Empty)
            {
                return true;
            }
            if (txtCounty.Text.Trim() == String.Empty)
            {
                return true;
            }
            return false;
        }

        private void btnRefresh_Click(object sender, EventArgs e)
        {
            Form1_Load(sender, e);
        }

        private void Mount(object sender, EventArgs e)
        {

        }

        private void lnkAbout_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            MessageBox.Show("Created for personal use. \nBy Noah Hebert, Nick Dekofski, Caitlin Griffin and Paul Fierce\n©2015", "About");
        }

<<<<<<< HEAD
=======
        private void panel1_Paint(object sender, PaintEventArgs e)
        {

        }

>>>>>>> b7e3c4ccf1c213a55ebeab0adc9a01c3b073719c


    }
}
