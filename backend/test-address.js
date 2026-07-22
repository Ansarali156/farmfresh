async function run() {
  try {
    const loginRes = await fetch('http://localhost:3000/api/v1/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ username: 'customer@farmfresh.com', password: 'password123' })
    });
    const login = await loginRes.json();
    const token = login.data.accessToken;
    
    const createRes = await fetch('http://localhost:3000/api/v1/addresses', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token },
      body: JSON.stringify({
        label: 'Home',
        street: '123 Main St',
        city: 'Hyderabad',
        state: 'TS',
        zipCode: '500001',
        country: 'India'
      })
    });
    const create = await createRes.json();
    const id = create.data.id;
    console.log("Created ID:", id);
    
    const updateRes = await fetch('http://localhost:3000/api/v1/addresses/' + id, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token },
      body: JSON.stringify({
        label: 'Work',
        street: '123 Main St',
        city: 'Hyderabad',
        state: 'TS',
        zipCode: '500001',
        country: 'India',
        isDefault: false
      })
    });
    const update = await updateRes.json();
    console.log("Updated:", update);
  } catch (err) {
    console.error(err);
  }
}
run();
