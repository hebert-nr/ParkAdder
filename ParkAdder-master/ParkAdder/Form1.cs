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


        SqlConnection con = new SqlConnection("Data source = localhost;Initial Catalog=thePPF;Integrated Security=True ");

        public Form1()
        {
            InitializeComponent();

            cboState.Items.Add(new State { Name = "AL", Value = "AL" });
            cboState.Items.Add(new State { Name = "AK", Value = "AK" });
            cboState.Items.Add(new State { Name = "AZ", Value = "AZ" });
            cboState.Items.Add(new State { Name = "AR", Value = "AR" });
            cboState.Items.Add(new State { Name = "CA", Value = "CA" });
            cboState.Items.Add(new State { Name = "CO", Value = "CO" });
            cboState.Items.Add(new State { Name = "CT", Value = "CT" });
            cboState.Items.Add(new State { Name = "DE", Value = "DE" });
            cboState.Items.Add(new State { Name = "FL", Value = "FL" });
            cboState.Items.Add(new State { Name = "GA", Value = "GA" });
            cboState.Items.Add(new State { Name = "HI", Value = "HI" });
            cboState.Items.Add(new State { Name = "ID", Value = "ID" });
            cboState.Items.Add(new State { Name = "IL", Value = "IL" });
            cboState.Items.Add(new State { Name = "IN", Value = "IN" });
            cboState.Items.Add(new State { Name = "IA", Value = "IA" });
            cboState.Items.Add(new State { Name = "KS", Value = "KS" });
            cboState.Items.Add(new State { Name = "KY", Value = "KY" });
            cboState.Items.Add(new State { Name = "LA", Value = "LA" });
            cboState.Items.Add(new State { Name = "ME", Value = "ME" });
            cboState.Items.Add(new State { Name = "MD", Value = "MD" });
            cboState.Items.Add(new State { Name = "MA", Value = "MA" });
            cboState.Items.Add(new State { Name = "MI", Value = "MI" });
            cboState.Items.Add(new State { Name = "MN", Value = "MN" });
            cboState.Items.Add(new State { Name = "MS", Value = "MS" });
            cboState.Items.Add(new State { Name = "MO", Value = "MO" });
            cboState.Items.Add(new State { Name = "MT", Value = "MT" });
            cboState.Items.Add(new State { Name = "NE", Value = "NE" });
            cboState.Items.Add(new State { Name = "NV", Value = "NV" });
            cboState.Items.Add(new State { Name = "NH", Value = "NH" });
            cboState.Items.Add(new State { Name = "NJ", Value = "NJ" });
            cboState.Items.Add(new State { Name = "NM", Value = "NM" });
            cboState.Items.Add(new State { Name = "NY", Value = "NY" });
            cboState.Items.Add(new State { Name = "NC", Value = "NC" });
            cboState.Items.Add(new State { Name = "ND", Value = "ND" });
            cboState.Items.Add(new State { Name = "OH", Value = "OH" });
            cboState.Items.Add(new State { Name = "OK", Value = "OK" });
            cboState.Items.Add(new State { Name = "OR", Value = "OR" });
            cboState.Items.Add(new State { Name = "PA", Value = "PA" });
            cboState.Items.Add(new State { Name = "RI", Value = "RI" });
            cboState.Items.Add(new State { Name = "SC", Value = "SC" });
            cboState.Items.Add(new State { Name = "SD", Value = "SD" });
            cboState.Items.Add(new State { Name = "TN", Value = "TN" });
            cboState.Items.Add(new State { Name = "TX", Value = "TX" });
            cboState.Items.Add(new State { Name = "UT", Value = "UT" });
            cboState.Items.Add(new State { Name = "VT", Value = "VT" });
            cboState.Items.Add(new State { Name = "VA", Value = "VA" });
            cboState.Items.Add(new State { Name = "WA", Value = "WA" });
            cboState.Items.Add(new State { Name = "WV", Value = "WV" });
            cboState.Items.Add(new State { Name = "WI", Value = "WI" });
            cboState.Items.Add(new State { Name = "WY", Value = "WY" });
            cboState.Items.Add(new State { Name = "DC", Value = "DC" });
            
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

                   
                    SqlCommand addFeat = new SqlCommand("IF NOT EXISTS (Select PID, FID From FeaturesAtPark Where PID = " + cboName.SelectedValue + " AND FID = " + featureID + ") Insert Into FeaturesAtPark (PID,FID) Values("
                                                        + cboName.SelectedValue + ", " + featureID + ")");

                    addFeat.Connection = con;
                    addFeat.ExecuteNonQuery();
                    
                }
                MessageBox.Show("Features Added!");
                lboFeature.ClearSelected();
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
            SqlCommand command = new SqlCommand("SELECT ParkID, ParkName FROM thePPF.dbo.Park ORDER BY ParkId Desc", con);
            SqlCommand comFeat = new SqlCommand("Select FeatureID, FeatureName FROM thePPF.dbo.Feature", con);

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
            cboState.SelectedItem = null;
            txtAddZip.Clear();
            txtCounty.Clear();
            txtLong.Clear();
            txtLat.Clear();
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
                    MessageBox.Show("Please fill in all boxes before adding");
                    con.Close();

                }
                else
                {
                    SqlCommand cmd = new SqlCommand("insert into Park(ParkName, StreetAddress, City, County, ZipCode, Longitude, Latitude, State) values(@name, @address, @city, @county, @zip, @latitude, @longitude, @state)", con);

                    cmd.Parameters.AddWithValue("@name", txtAddName.Text);
                    cmd.Parameters.AddWithValue("@address", txtAddAddress.Text);
                    cmd.Parameters.AddWithValue("@city", txtAddCity.Text);
                    cmd.Parameters.AddWithValue("@county", txtCounty.Text);
                    cmd.Parameters.AddWithValue("@state", cboState.SelectedItem.ToString());
                    cmd.Parameters.AddWithValue("@zip", txtAddZip.Text);
                    cmd.Parameters.AddWithValue("@latitude", txtLat.Text);
                    cmd.Parameters.AddWithValue("@longitude", txtLong.Text);

                    SqlDataReader reader;
                    reader = cmd.ExecuteReader();

                    txtAddAddress.Clear();
                    txtAddName.Clear();
                    txtAddCity.Clear();
                    txtAddZip.Clear();
                    cboState.SelectedItem = null;
                    txtCounty.Clear();
                    txtLong.Clear();
                    txtLat.Clear();

                    MessageBox.Show("Saved!");
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
            } if (cboState.SelectedItem == null)
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
            if (txtLong.Text.Trim() == String.Empty)
            {
                return true;
            }
            if (txtLat.Text.Trim() == String.Empty)
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

    }
}
